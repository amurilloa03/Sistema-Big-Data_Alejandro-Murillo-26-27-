# Script 03 - Índices (explicado paso a paso)

## Qué es un índice

Es como el índice de un libro. Sin índice, para encontrar algo tienes que leer el libro entero. Con índice, vas directo a la página.

En MongoDB:
- **Sin índice:** mira todos los documentos uno a uno. Se llama **COLLSCAN**.
- **Con índice:** va directo a los que necesita. Se llama **IXSCAN**.

Con 12 productos no se nota, pero con un millón sí.

Antes de empezar, en la consola tiene que poner `tienda_electronica>`. Si no:

```js
use tienda_electronica
```

## Paso 1 · Ver los índices que hay

```js
db.productos.getIndexes()
```

Solo sale `_id_`. MongoDB siempre crea un índice sobre el `_id`, como una clave primaria en SQL.

## Paso 2 · Cómo busca SIN índice

Esta es la consulta de la pregunta 1 (móviles ordenados por precio):

```js
db.productos.find({ categoria: "moviles", activo: true }).sort({ precio: -1 })
```

Salen 3 móviles. Ahora le pregunto cómo los ha buscado con `explain`:

```js
db.productos.find({ categoria: "moviles", activo: true }).sort({ precio: -1 }).explain("executionStats").executionStats
```

- `explain("executionStats")` significa "no me des los productos, dime cómo los has buscado".
- El `.executionStats` del final es para que solo enseñe los números importantes.

Hay que mirar estas líneas:

```
nReturned: 3            -> ha devuelto 3
totalKeysExamined: 0    -> ha mirado 0 entradas de índice (no hay)
totalDocsExamined: 12   -> ha mirado los 12 productos
```

Ha mirado 12 para encontrar 3. Eso es lo malo.

Para ver el tipo de búsqueda:

```js
db.productos.find({ categoria: "moviles", activo: true }).sort({ precio: -1 }).explain().queryPlanner.winningPlan
```

Sale `SORT` y dentro `COLLSCAN`: ha recorrido todo y luego lo ha ordenado en memoria.

📸 Captura del "ANTES".
![foto1](/PracticaUT2_01_Murillo_Alejandro/img/img3.1.png)

## Paso 3 · Crear el índice

```js
db.productos.createIndex({ categoria: 1, precio: -1 }, { name: "idx_categoria_precio" })
```

- Es un índice **compuesto** porque tiene 2 campos.
- `1` es orden ascendente y `-1` descendente. El precio va con `-1` porque ordeno de más caro a más barato.
- Primero va la categoría porque es por lo que **filtro**, y luego el precio porque es por lo que **ordeno**. Así MongoDB va a la parte de "moviles" del índice y los coge ya ordenados.
- `name` es el nombre que le pongo.

## Paso 4 · Cómo busca CON índice

```js
db.productos.find({ categoria: "moviles", activo: true }).sort({ precio: -1 }).explain("executionStats").executionStats
```

Ahora sale:

```
nReturned: 3
totalKeysExamined: 3
totalDocsExamined: 3
```

Antes miraba 12 y ahora 3.

```js
db.productos.find({ categoria: "moviles", activo: true }).sort({ precio: -1 }).explain().queryPlanner.winningPlan
```

Ahora sale `IXSCAN` y ya no sale `SORT`, porque los datos vienen ordenados del índice.

📸 Captura del "DESPUÉS".

## Paso 5 · Lo mismo con las reseñas (pregunta 4)

Antes:

```js
db.resenas.find({ producto_id: "PROD-001" }).sort({ fecha: -1 }).limit(5).explain("executionStats").executionStats
```

`totalDocsExamined: 40`: mira las 40 reseñas para encontrar las 4 del Galaxy.

Creo el índice:

```js
db.resenas.createIndex({ producto_id: 1, fecha: -1 }, { name: "idx_producto_fecha" })
```

Después:

```js
db.resenas.find({ producto_id: "PROD-001" }).sort({ fecha: -1 }).limit(5).explain("executionStats").executionStats
```

`totalDocsExamined: 4`. De 40 a 4.

## Paso 6 · Índice de marca y precio (pregunta 2)

```js
db.productos.createIndex({ marca: 1, precio: 1 }, { name: "idx_marca_precio" })
```

Lo pruebo:

```js
db.productos.find({ marca: "Samsung", precio: { $gte: 500, $lte: 1000 } })
```

- `$gte` es "mayor o igual que".
- `$lte` es "menor o igual que".
- Juntos: precio entre 500 y 1000.

Salen 3 productos Samsung.

## Paso 7 · Índice de texto (pregunta 7)

Sirve para buscar palabras dentro de un texto, como el buscador de una tienda.

```js
db.productos.createIndex({ nombre: "text" }, { name: "idx_texto_nombre", default_language: "spanish" })
```

- `"text"` en vez de `1` o `-1` hace que sea un índice de texto: guarda cada palabra del nombre por separado.
- `default_language: "spanish"` hace que entienda el español, así "inalámbrico" también encuentra "inalámbricos".

Lo pruebo:

```js
db.productos.find({ $text: { $search: "inalámbrico" } }, { nombre: 1 })
```

Salen los Sony, los Xiaomi Buds y el ratón Logitech.

Si lo intento en una colección sin índice de texto, falla:

```js
db.usuarios.find({ $text: { $search: "Laura" } })
```

Error `text index required`. La búsqueda `$text` no funciona sin índice de texto.

## Paso 8 · Índice único (email)

```js
db.usuarios.createIndex({ email: 1 }, { name: "idx_email_unico", unique: true })
```

`unique: true` hace que no pueda haber dos documentos con el mismo valor.

Lo pruebo metiendo otro usuario con el email de Laura:

```js
db.usuarios.insertOne({ _id: "USR-06", nombre: "Otra Laura", email: "laura@ejemplo.com", rol: "cliente" })
```

Falla con `duplicate key error`.

## Paso 9 · Ver todos los índices

```js
db.productos.getIndexes()
db.resenas.getIndexes()
db.usuarios.getIndexes()
```

En productos hay 4 (`_id_`, categoría, marca y texto), en reseñas 2 y en usuarios 2.

En Compass también se ven: colección → pestaña **Indexes**. 📸 Captura.

**Coste:** los índices ocupan espacio y hacen que insertar sea un poco más lento, porque MongoDB también tiene que actualizar el índice. Por eso solo se crean los que responden a una pregunta. En una tienda compensa porque se lee mucho más de lo que se escribe.

## Paso 10 · El script final

El script `03-indices.js` hace todo lo anterior en orden:

1. Borra los índices que haya (`dropIndexes`) para poder ver el "antes".
2. Hace el explain ANTES.
3. Crea los 5 índices.
4. Hace el explain DESPUÉS.

Lo nuevo del script:
- **`function verPlan(titulo, consulta)`**: una función normal de JavaScript para no repetir el explain. Recibe la consulta y escribe los números.
- **`const consultaCategoria = () => ...`**: guarda la consulta en una variable (función flecha) para usarla antes y después sin escribirla dos veces.
- **`JSON.stringify(...).match(...)`**: convierte el plan en texto y saca solo las etapas (COLLSCAN, IXSCAN, SORT...) para que se lea fácil.
- **`dropIndexes()`**: borra todos los índices menos el de `_id`.

Para ejecutarlo: copia todo el `03-indices.js`, pégalo en la consola de Compass y dale a Enter.

Tiene que salir algo así:

```
========== ANTES DE CREAR LOS ÍNDICES ==========
P1 - móviles ordenados por precio
   etapas: "stage":"SORT" "stage":"COLLSCAN"
   documentos examinados: 12 | claves de índice examinadas: 0 | devueltos: 3 | tiempo: 0 ms
P4 - últimas reseñas de PROD-001
   etapas: "stage":"SORT" "stage":"COLLSCAN"
   documentos examinados: 40 | claves de índice examinadas: 0 | devueltos: 4 | tiempo: 0 ms

Índices de productos: _id_, idx_categoria_precio, idx_marca_precio, idx_texto_nombre
Índices de resenas: _id_, idx_producto_fecha
Índices de usuarios: _id_, idx_email_unico

========== DESPUÉS DE CREAR LOS ÍNDICES ==========
P1 - móviles ordenados por precio
   etapas: "stage":"FETCH" "stage":"IXSCAN"
   documentos examinados: 3 | claves de índice examinadas: 3 | devueltos: 3 | tiempo: 0 ms
P4 - últimas reseñas de PROD-001
   etapas: "stage":"LIMIT" "stage":"FETCH" "stage":"IXSCAN"
   documentos examinados: 4 | claves de índice examinadas: 4 | devueltos: 4 | tiempo: 0 ms
```

- **FETCH**: después de encontrar en el índice dónde están, va a por los documentos completos.
- **LIMIT**: es el `.limit(5)`.

Si alguna etapa sale con un nombre un poco distinto no pasa nada. Lo importante es que antes salga `COLLSCAN`, después `IXSCAN`, y que bajen los documentos examinados.

📸 Captura de todo el resultado: es la evidencia del explain antes y después.