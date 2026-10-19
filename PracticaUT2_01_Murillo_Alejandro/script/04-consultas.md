# Consultas

Todas las consultas están en `scripts/04-consultas.js`.

## CRUD

### Insertar un producto

```js
db.productos.insertOne({
  _id: "PROD-013",
  nombre: "Teclado inalámbrico Logitech K380",
  marca: "Logitech",
  categoria: "accesorios",
  precio: 49.99,
  activo: true,
  fecha_alta: new Date(),
  variantes: [
    { sku: "K380-NEG", color: "Negro", stock: NumberInt(10) },
    { sku: "K380-ROS", color: "Rosa", stock: NumberInt(6) }
  ]
})
```

Añade un teclado nuevo al catálogo con dos colores.

### Actualizar el precio y el stock

```js
db.productos.updateOne(
  { _id: "PROD-013", "variantes.sku": "K380-ROS" },
  { $set: { precio: 44.99 }, $inc: { "variantes.$.stock": NumberInt(5) } }
)
```

Baja el precio con `$set` y suma 5 unidades solo a la variante rosa con `$inc`. El `$` de `variantes.$.stock` es la variante que coincide con el filtro.

### Desactivar un producto

```js
db.productos.updateOne(
  { _id: "PROD-013" },
  { $set: { activo: false, fecha_baja: new Date() } }
)
```

Borrado lógico: el producto deja de salir en la tienda, pero no se borra porque puede tener reseñas.

### Eliminar una reseña

```js
db.resenas.deleteOne({ comentario: "Reseña de prueba para borrar" })
```

Borra de verdad una reseña de prueba.

## Preguntas de negocio

### 1. Productos de una categoría ordenados por precio

```js
db.productos.find({ categoria: "moviles", activo: true }, { nombre: 1, precio: 1 })
  .sort({ precio: -1, _id: 1 }).skip(0).limit(2)
```

Saca los móviles del más caro al más barato, de 2 en 2. Para la página 2 se cambia a `skip(2)`. El `_id` en el `sort` es para que, si dos cuestan lo mismo, no cambien de página.

### 2. Productos de una marca entre dos precios

```js
db.productos.find(
  { marca: "Samsung", precio: { $gte: 500, $lte: 1000 }, activo: true },
  { nombre: 1, precio: 1 }
).sort({ precio: 1 })
```

Productos Samsung que cuestan entre 500 y 1000 €. `$gte` es "mayor o igual" y `$lte` "menor o igual".

### 3. Variantes y stock de un producto

```js
db.productos.findOne({ _id: "PROD-001" }, { nombre: 1, variantes: 1 })
```

Como las variantes están dentro del producto, sale todo con una sola consulta.

### 4. Últimas reseñas de un producto

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

Las 5 reseñas más nuevas del Galaxy S24. Con `$lookup` saco el nombre del usuario de la colección usuarios, porque en la reseña solo está su id. El `$lookup` va después del `$limit` para que solo busque 5 usuarios.

### 5. Valoración media de cada producto (agregación compleja)

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

- `$group` junta las reseñas de cada producto y calcula la media y cuántas hay.
- `$lookup` y `$unwind` traen el nombre del producto.
- `$project` redondea la media y elige los campos.
- `$sort` ordena del mejor valorado al peor.

Sale el Lenovo IdeaPad el primero (4,75) y el Galaxy Book4 el último (3). Si hubiera millones de reseñas, el `$group` tardaría porque tiene que leerlas todas. Sería mejor guardar la media en el producto y actualizarla con cada reseña nueva.

### 6. Productos con poco stock

```js
db.productos.aggregate([
  { $match: { activo: true } },
  { $unwind: "$variantes" },
  { $match: { "variantes.stock": { $lt: 5 } } },
  { $project: { _id: 0, producto: "$nombre", sku: "$variantes.sku", stock: "$variantes.stock" } },
  { $sort: { stock: 1 } }
])
```

`$unwind` separa las variantes en un documento cada una, y luego me quedo con las que tienen menos de 5 unidades. La primera es el ratón Logitech gris claro, con 0.

### 7. Productos con una palabra en el nombre

```js
db.productos.find({ $text: { $search: "inalámbrico" }, activo: true }, { nombre: 1, precio: 1 })
```

Busca "inalámbrico" en el nombre usando el índice de texto. Salen los auriculares Sony, los Xiaomi Buds y el ratón Logitech.
