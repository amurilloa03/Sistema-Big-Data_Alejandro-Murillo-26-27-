# Práctica 01 - Base de datos documental con MongoDB
 
Alejandro Murillo - Sistemas de Big Data (UT2)
 
Escenario elegido: **catálogo de una tienda de electrónica**
 
## 1. Definir el problema y los accesos
 
### Escenario y usuarios
 
El escenario es una tienda online de electrónica (móviles, portátiles, audio, televisores y accesorios) en la que los clientes buscan productos, miran los colores o capacidades que hay y leen las reseñas.
 
Hay dos tipos de usuario:
- **Cliente**: busca productos, mira el stock y escribe reseñas.
- **Administrador**: añade productos, cambia precios, actualiza el stock y mira qué se está acabando.
### Preguntas de negocio
 
1. ¿Qué productos hay de una categoría, ordenados por precio?
2. ¿Qué productos de una marca cuestan entre un precio mínimo y uno máximo?
3. ¿Qué variantes tiene un producto y cuánto stock queda de cada una?
4. ¿Cuáles son las últimas reseñas de un producto?
5. ¿Cuál es la valoración media de cada producto?
6. ¿Qué productos tienen poco stock (menos de 5 unidades)?
7. ¿Qué productos contienen una palabra en su nombre (por ejemplo "inalámbrico")?
### Datos que más se leen y escriben
 
Lo que más se lee es el catálogo de productos, es decir, buscar productos, entrar a verlos y mirar si hay stock o no.
 
Lo que más se escribe es el stock (cuando alguien compra o llega mercancía) y las reseñas nuevas. Añadir o quitar productos se hace menos.
 
Como se lee mucho más de lo que se escribe, me interesa que leer sea rápido. Por eso he metido las variantes dentro del producto y he creado índices.
 
### Tabla de preguntas
 
| Pregunta | Colección | Filtros | Ordenación | Paginación |
|---|---|---|---|---|
| 1 | productos | categoria, activo | precio de mayor a menor | sí (skip y limit) |
| 2 | productos | marca, precio entre mínimo y máximo | precio de menor a mayor | sí |
| 3 | productos | _id del producto | no | no, es un solo producto |
| 4 | resenas (+ usuarios) | producto_id | fecha, las más nuevas primero | las 5 últimas |
| 5 | resenas (+ productos) | todas, agrupadas por producto | media de mayor a menor | no |
| 6 | productos | activo y stock < 5 | stock de menor a mayor | no |
| 7 | productos | buscar texto en el nombre | por relevancia | no |
 
### Requisitos
 
- **Seguridad**: autenticación con usuario y contraseña y 2FA (doble factor) para los administradores. Cada usuario de la base de datos tiene solo los permisos que necesita.
- **Privacidad**: cumplir la ley (RGPD) al tratar información personal y pedir solo los datos que son 100% necesarios. De los usuarios solo guardo el nombre y el email.
- **Disponibilidad**: tolerancia a fallos y redundancia. Con un replica set hay varias copias de los datos en distintos servidores, y si uno se cae sigue funcionando otro.
- **Crecimiento**: tener escalabilidad vertical (un servidor más potente) y horizontal (repartir los datos entre varios servidores con sharding) para que sea lo más barato posible y pueda crecer con el tiempo.
## 2. Diseño de las colecciones
 
### Colecciones
 
- **productos**: el catálogo. Cada producto lleva dentro sus variantes (color, capacidad y stock).
- **usuarios**: los clientes y los administradores.
- **resenas**: las opiniones de los clientes, de 1 a 5 estrellas.
Esquema:
 
```
productos                   resenas                    usuarios
---------                   -------                    --------
_id (PROD-001)  <--------   producto_id                _id (USR-01)
nombre                      usuario_id     -------->   nombre
marca                       estrellas                  email
categoria                   comentario                 rol
precio                      fecha                      fecha_registro
activo
fecha_alta
variantes [ ]  (dentro del producto)
   sku
   color
   capacidad
   stock
```
 
Un producto puede tener muchas reseñas y un usuario puede escribir muchas reseñas.
 
### Documentos de ejemplo
 
Producto:
 
```json
{
  "_id": "PROD-001",
  "nombre": "Samsung Galaxy S24",
  "marca": "Samsung",
  "categoria": "moviles",
  "precio": 799.99,
  "activo": true,
  "fecha_alta": { "$date": "2026-01-15T00:00:00Z" },
  "variantes": [
    { "sku": "S24-NEG-128", "color": "Negro", "capacidad": "128GB", "stock": 12 },
    { "sku": "S24-VIO-256", "color": "Violeta", "capacidad": "256GB", "stock": 3 }
  ]
}
```
 
Usuario:
 
```json
{
  "_id": "USR-01",
  "nombre": "Laura Gómez",
  "email": "laura@ejemplo.com",
  "rol": "cliente",
  "fecha_registro": { "$date": "2025-11-02T00:00:00Z" }
}
```
 
Reseña:
 
```json
{
  "_id": { "$oid": "6701a2c4e1b2c3d4e5f60718" },
  "producto_id": "PROD-001",
  "usuario_id": "USR-01",
  "estrellas": 5,
  "comentario": "Muy buena calidad, lo recomiendo",
  "fecha": { "$date": "2026-09-01T00:00:00Z" }
}
```
 
### Incrustar o referenciar
 
**Las variantes las he incrustado dentro del producto.** Son datos pequeños (sku, color, capacidad y stock) y siempre que alguien entra a ver un producto hay que enseñar sus variantes, así que se leen juntos. Además son pocas: un producto tiene entre 1 y 10 variantes y no van a crecer sin parar. Para cambiar el stock de una sola variante uso `$inc` con `variantes.$` y no hace falta reescribir el producto entero. Así con una sola consulta tengo todo el producto.
 
**Las reseñas las he puesto en otra colección y las referencio con `producto_id` y `usuario_id`.** Un producto que se vende mucho puede tener miles de reseñas. Si las metiera dentro del producto, el documento crecería sin límite y podría llegar a los 16 MB, que es lo máximo que deja MongoDB por documento. Además las reseñas no hacen falta siempre, solo cuando el cliente baja a verlas, y se están añadiendo todo el rato. Cuando necesito juntar datos uso `$lookup`.
 
### Identificadores, fechas, estados y campos opcionales
 
- **Ids**: en productos y usuarios he puesto códigos propios (PROD-001, USR-01) porque se leen mejor y es más fácil referenciarlos. En las reseñas dejo el ObjectId que pone MongoDB solo.
- **Fechas**: siempre como tipo Date, no como texto, para poder ordenar y filtrar.
- **Estados**: un producto está activo o no (`activo: true/false`). Los productos no los borro porque pueden tener reseñas, solo los desactivo. El rol del usuario solo puede ser `cliente` o `admin`.
- **Campos opcionales**: si un campo no tiene sentido, directamente no lo pongo. Por ejemplo, un altavoz no tiene capacidad y una tele no tiene color. `fecha_baja` solo aparece cuando se desactiva un producto.
### Límites del modelo
 
- **16 MB por documento**: no es un problema porque un producto ocupa muy poco y las reseñas, que es lo que crece, están fuera.
- **Arrays**: el único array es `variantes` y tiene pocos elementos. Si hubiera productos con cientos de variantes habría que sacarlas a otra colección.
- **Duplicación**: casi no hay datos repetidos. Lo malo es que para sacar el nombre del usuario de una reseña necesito un `$lookup`.
- **Consistencia**: si borrara un producto, sus reseñas apuntarían a algo que ya no existe. Por eso uso el borrado lógico.
- **Cosas incómodas**: para mirar el stock de todas las variantes hay que usar `$unwind`, y la valoración media no está guardada en el producto, hay que calcularla cada vez con una agregación.
## 3. Validación e índices
 
### Validación
 
Está en `scripts/01-colecciones-validacion.js`. He usado `$jsonSchema` en las tres colecciones:
 
- **productos**: campos obligatorios, el `_id` tiene que tener el formato PROD-000, la categoría tiene que ser una de la lista (enum), el precio no puede ser negativo, tiene que haber al menos una variante y el stock tiene que ser un número entero mayor o igual que 0.
- **usuarios**: campos obligatorios, el email tiene que tener formato de email y el rol solo puede ser cliente o admin.
- **resenas**: campos obligatorios, las estrellas tienen que ser un entero entre 1 y 5, el comentario como mucho 500 caracteres y la fecha de tipo Date.
Al final del script intento meter datos mal (precio negativo, una categoría que no existe, una reseña de 7 estrellas y un email sin @) y MongoDB no deja meter ninguno.
 
### Índices
 
Están en `scripts/03-indices.js`.
 
1. **`{ categoria: 1, precio: -1 }`** (compuesto) para la pregunta 1. Primero va la categoría porque filtro por ella y luego el precio porque ordeno por él, así los resultados ya salen ordenados.
2. **`{ marca: 1, precio: 1 }`** (compuesto) para la pregunta 2. Primero la marca y luego el precio, que es el rango.
3. **`{ producto_id: 1, fecha: -1 }`** en resenas, para las preguntas 4 y 5. Busca solo las reseñas de ese producto y ya ordenadas de la más nueva a la más vieja.
4. **`{ nombre: "text" }`** (de texto) para la pregunta 7. Sirve para buscar palabras en el nombre. Lo he puesto en español para que encuentre también "inalámbricos".
5. **`{ email: 1 }`** único en usuarios, para que no se puedan repetir emails.
Los índices ocupan espacio y hacen que insertar y actualizar sea un poco más lento, porque MongoDB tiene que actualizar también el índice. Aun así compensa, porque en una tienda se lee mucho más de lo que se escribe. El de texto es el que más ocupa porque guarda cada palabra del nombre.
 
### Explain antes y después
 
He comparado dos consultas con `explain("executionStats")`:
 
| Consulta | | Etapa | Docs examinados | Devueltos |
|---|---|---|---|---|
| Móviles por precio | antes | COLLSCAN + SORT | 12 | 3 |
| Móviles por precio | después | IXSCAN | 3 | 3 |
| Reseñas de PROD-001 | antes | COLLSCAN + SORT | 40 | 4 |
| Reseñas de PROD-001 | después | IXSCAN | 4 | 4 |
 
Sin índice MongoDB se lee todos los documentos (COLLSCAN) y luego los ordena en memoria (SORT). Con el índice va directo a los que necesita (IXSCAN) y ya están ordenados. Como hay pocos datos, el tiempo sale 0 ms en los dos casos, pero se nota en los documentos examinados. Con miles de productos la diferencia sería bastante grande.
 
Las capturas están en `docs/evidencias`.
 
## 4. Consultas y agregación
 
Todo está en `scripts/04-consultas.js`.
 
### CRUD
 
- **Insertar**: añado un producto nuevo (PROD-013, un teclado Logitech) con `insertOne`.
- **Actualizar**: le bajo el precio con `$set` y le sumo 5 unidades a una variante con `$inc`.
- **Desactivar**: le pongo `activo: false` y `fecha_baja` en vez de borrarlo.
- **Eliminar**: borro una reseña con `deleteOne`.
### Respuesta a cada pregunta
 
**1. ¿Qué productos hay de una categoría, ordenados por precio?**
 
```js
db.productos.find({ categoria: "moviles", activo: true }, { nombre: 1, precio: 1 })
  .sort({ precio: -1, _id: 1 }).skip(0).limit(2)
```
 
Saca los móviles del más caro al más barato, de 2 en 2. Para la página 2 se pone `skip(2)`. Ordeno también por `_id` para que, si dos productos cuestan lo mismo, no cambien de página.
 
Resultado: iPhone 15 (899 €), Samsung Galaxy S24 (799,99 €) y, en la página 2, Xiaomi Redmi Note 13 (249,99 €).
 
**2. ¿Qué productos de una marca cuestan entre un precio mínimo y uno máximo?**
 
```js
db.productos.find(
  { marca: "Samsung", precio: { $gte: 500, $lte: 1000 }, activo: true },
  { nombre: 1, precio: 1 }
).sort({ precio: 1 })
```
 
Resultado: Samsung Galaxy S24 (799,99 €), Portátil Samsung Galaxy Book4 (849,99 €) y Televisor Samsung QLED 65 pulgadas (999,99 €).
 
**3. ¿Qué variantes tiene un producto y cuánto stock queda de cada una?**
 
```js
db.productos.findOne({ _id: "PROD-001" }, { nombre: 1, variantes: 1 })
```
 
Como las variantes están dentro del producto, sale todo con una sola consulta.
 
Resultado: Samsung Galaxy S24 tiene Negro 128GB con 12 unidades y Violeta 256GB con 3 unidades.
 
**4. ¿Cuáles son las últimas reseñas de un producto?**
 
```js
db.resenas.aggregate([
  { $match: { producto_id: "PROD-001" } },
  { $sort: { fecha: -1 } },
  { $limit: 5 },
  { $lookup: { from: "usuarios", localField: "usuario_id", foreignField: "_id", as: "usuario" } },
  { $unwind: "$usuario" },
  { $project: { _id: 0, estrellas: 1, comentario: 1, fecha: 1, usuario: "$usuario.nombre" } }
])
```
 
Uso `$lookup` para sacar el nombre del usuario, porque en la reseña solo está su id.
 
Resultado: salen las 4 reseñas del Galaxy S24, de la más nueva a la más vieja. La primera es la de Laura Gómez del 21 de septiembre (5 estrellas, "Esperaba más por el precio") y la siguiente la de Marta Sánchez del 11 de septiembre (4 estrellas).
 
**5. ¿Cuál es la valoración media de cada producto?**
 
Esta es la agregación compleja, explicada en el apartado siguiente.
 
Resultado: el mejor valorado es el Lenovo IdeaPad Slim 5 (4,75), luego el Samsung Galaxy S24 (4,25) y el JBL Flip 6 (4). El peor es el Samsung Galaxy Book4 (3).
 
**6. ¿Qué productos tienen poco stock (menos de 5 unidades)?**
 
```js
db.productos.aggregate([
  { $match: { activo: true } },
  { $unwind: "$variantes" },
  { $match: { "variantes.stock": { $lt: 5 } } },
  { $project: { _id: 0, producto: "$nombre", sku: "$variantes.sku", stock: "$variantes.stock" } },
  { $sort: { stock: 1 } }
])
```
 
`$unwind` separa las variantes para poder mirar el stock de cada una por separado.
 
Resultado: salen 8 variantes. La peor es el ratón Logitech gris claro, con 0 unidades, seguida de los Sony plata con 1, y el iPhone 15 azul y la tele Samsung, con 2 cada uno.
 
**7. ¿Qué productos contienen una palabra en su nombre?**
 
```js
db.productos.find({ $text: { $search: "inalámbrico" }, activo: true }, { nombre: 1, precio: 1 })
```
 
Usa el índice de texto del nombre.
 
Resultado: los auriculares Sony WH-1000XM5, los Xiaomi Redmi Buds 5 y el ratón Logitech MX Master 3S. El teclado Logitech que añado en el CRUD no sale porque lo he desactivado.
 
### Agregación compleja (pregunta 5)
 
```js
db.resenas.aggregate([
  { $group: { _id: "$producto_id", media: { $avg: "$estrellas" }, total_resenas: { $sum: 1 } } },
  { $lookup: { from: "productos", localField: "_id", foreignField: "_id", as: "producto" } },
  { $unwind: "$producto" },
  { $project: { _id: 0, producto: "$producto.nombre", categoria: "$producto.categoria",
                media: { $round: ["$media", 2] }, total_resenas: 1 } },
  { $sort: { media: -1 } }
])
```
 
Lo que hace cada etapa:
1. `$group` junta las reseñas de cada producto y saca la media de estrellas y cuántas tiene.
2. `$lookup` busca en productos los datos de cada uno.
3. `$unwind` convierte en objeto el array que devuelve el `$lookup`.
4. `$project` elige los campos que quiero enseñar y redondea la media.
5. `$sort` ordena del mejor valorado al peor.
El resultado es una lista con los 10 productos que tienen reseñas, con su media y el número de reseñas.
 
Si hubiera muchos más datos, el `$group` tendría que leerse todas las reseñas, así que con millones tardaría bastante. Lo bueno es que el `$lookup` va después de agrupar, así que solo busca una vez por producto y no una vez por reseña. Si la tienda creciera mucho, sería mejor guardar la media en el producto y actualizarla cada vez que llega una reseña nueva.
 
## 5. Seguridad y límites
 

## 6. Revisión
 
- Los scripts empiezan con la base de datos vacía.
- Se ejecutan en orden: 01, 02, 03 y 04.
- Los datos son inventados y tienen sentido para una tienda de electrónica.
- No hay contraseñas ni cadenas de conexión en el repositorio.
- Las capturas están en `docs/evidencias`.

