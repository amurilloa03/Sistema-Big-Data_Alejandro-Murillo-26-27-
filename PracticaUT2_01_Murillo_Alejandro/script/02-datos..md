# 02 - Datos de prueba

Script para MongoDB que rellena la base de datos `tienda_electronica` con datos de prueba **inventados** (no hay datos reales): 12 productos, 5 usuarios y 40 reseñas generadas con un bucle.

---

## Preparar las colecciones

Se selecciona la base de datos y se vacían las colecciones, para que el script se pueda ejecutar varias veces sin duplicar datos.

```javascript
db = db.getSiblingDB("tienda_electronica");

db.productos.deleteMany({});
db.usuarios.deleteMany({});
db.resenas.deleteMany({});
```

---

## Productos

12 productos repartidos entre las 5 categorías permitidas por el esquema.

| `_id` | Nombre | Marca | Categoría | Precio (€) | Variantes |
|---|---|---|---|---|---|
| PROD-001 | Samsung Galaxy S24 | Samsung | moviles | 799.99 | 2 |
| PROD-002 | iPhone 15 | Apple | moviles | 899 | 2 |
| PROD-003 | Xiaomi Redmi Note 13 | Xiaomi | moviles | 249.99 | 2 |
| PROD-004 | Portátil Lenovo IdeaPad Slim 5 | Lenovo | portatiles | 699.99 | 1 |
| PROD-005 | MacBook Air M3 | Apple | portatiles | 1299 | 2 |
| PROD-006 | Portátil Samsung Galaxy Book4 | Samsung | portatiles | 849.99 | 1 |
| PROD-007 | Auriculares inalámbricos Sony WH-1000XM5 | Sony | audio | 349.99 | 2 |
| PROD-008 | Altavoz Bluetooth JBL Flip 6 | JBL | audio | 129.99 | 3 |
| PROD-009 | Auriculares inalámbricos Xiaomi Redmi Buds 5 | Xiaomi | audio | 39.99 | 1 |
| PROD-010 | Televisor LG OLED 55 pulgadas | LG | televisores | 1199 | 1 |
| PROD-011 | Televisor Samsung QLED 65 pulgadas | Samsung | televisores | 999.99 | 1 |
| PROD-012 | Ratón inalámbrico Logitech MX Master 3S | Logitech | accesorios | 99.99 | 2 |

> La variante `MX3S-GRC` del ratón Logitech tiene `stock: 0`, que es válido porque el esquema pide un mínimo de 0.

```javascript
db.productos.insertMany([
  {
    _id: "PROD-001", nombre: "Samsung Galaxy S24", marca: "Samsung", categoria: "moviles",
    precio: 799.99, activo: true, fecha_alta: new Date("2026-01-15"),
    variantes: [
      { sku: "S24-NEG-128", color: "Negro", capacidad: "128GB", stock: NumberInt(12) },
      { sku: "S24-VIO-256", color: "Violeta", capacidad: "256GB", stock: NumberInt(3) }
    ]
  },
  {
    _id: "PROD-002", nombre: "iPhone 15", marca: "Apple", categoria: "moviles",
    precio: 899, activo: true, fecha_alta: new Date("2026-01-20"),
    variantes: [
      { sku: "IP15-NEG-128", color: "Negro", capacidad: "128GB", stock: NumberInt(8) },
      { sku: "IP15-AZU-128", color: "Azul", capacidad: "128GB", stock: NumberInt(2) }
    ]
  },
  {
    _id: "PROD-003", nombre: "Xiaomi Redmi Note 13", marca: "Xiaomi", categoria: "moviles",
    precio: 249.99, activo: true, fecha_alta: new Date("2026-02-03"),
    variantes: [
      { sku: "RN13-NEG", color: "Negro", capacidad: "256GB", stock: NumberInt(9) },
      { sku: "RN13-VER", color: "Verde", capacidad: "256GB", stock: NumberInt(15) }
    ]
  },
  {
    _id: "PROD-004", nombre: "Portátil Lenovo IdeaPad Slim 5", marca: "Lenovo", categoria: "portatiles",
    precio: 699.99, activo: true, fecha_alta: new Date("2026-02-10"),
    variantes: [
      { sku: "IPS5-GRI-512", color: "Gris", capacidad: "16GB/512GB", stock: NumberInt(6) }
    ]
  },
  {
    _id: "PROD-005", nombre: "MacBook Air M3", marca: "Apple", categoria: "portatiles",
    precio: 1299, activo: true, fecha_alta: new Date("2026-03-01"),
    variantes: [
      { sku: "MBA-PLA-256", color: "Plata", capacidad: "8GB/256GB", stock: NumberInt(4) },
      { sku: "MBA-MED-512", color: "Medianoche", capacidad: "16GB/512GB", stock: NumberInt(7) }
    ]
  },
  {
    _id: "PROD-006", nombre: "Portátil Samsung Galaxy Book4", marca: "Samsung", categoria: "portatiles",
    precio: 849.99, activo: true, fecha_alta: new Date("2026-03-12"),
    variantes: [
      { sku: "GB4-GRI-512", color: "Gris", capacidad: "16GB/512GB", stock: NumberInt(3) }
    ]
  },
  {
    _id: "PROD-007", nombre: "Auriculares inalámbricos Sony WH-1000XM5", marca: "Sony", categoria: "audio",
    precio: 349.99, activo: true, fecha_alta: new Date("2026-03-20"),
    variantes: [
      { sku: "XM5-NEG", color: "Negro", stock: NumberInt(10) },
      { sku: "XM5-PLA", color: "Plata", stock: NumberInt(1) }
    ]
  },
  {
    _id: "PROD-008", nombre: "Altavoz Bluetooth JBL Flip 6", marca: "JBL", categoria: "audio",
    precio: 129.99, activo: true, fecha_alta: new Date("2026-04-02"),
    variantes: [
      { sku: "FLIP6-NEG", color: "Negro", stock: NumberInt(20) },
      { sku: "FLIP6-AZU", color: "Azul", stock: NumberInt(14) },
      { sku: "FLIP6-ROJ", color: "Rojo", stock: NumberInt(4) }
    ]
  },
  {
    _id: "PROD-009", nombre: "Auriculares inalámbricos Xiaomi Redmi Buds 5", marca: "Xiaomi", categoria: "audio",
    precio: 39.99, activo: true, fecha_alta: new Date("2026-04-15"),
    variantes: [
      { sku: "BUDS5-BLA", color: "Blanco", stock: NumberInt(30) }
    ]
  },
  {
    _id: "PROD-010", nombre: "Televisor LG OLED 55 pulgadas", marca: "LG", categoria: "televisores",
    precio: 1199, activo: true, fecha_alta: new Date("2026-05-05"),
    variantes: [
      { sku: "LGOLED-55", capacidad: "55 pulgadas", stock: NumberInt(5) }
    ]
  },
  {
    _id: "PROD-011", nombre: "Televisor Samsung QLED 65 pulgadas", marca: "Samsung", categoria: "televisores",
    precio: 999.99, activo: true, fecha_alta: new Date("2026-05-20"),
    variantes: [
      { sku: "SQLED-65", capacidad: "65 pulgadas", stock: NumberInt(2) }
    ]
  },
  {
    _id: "PROD-012", nombre: "Ratón inalámbrico Logitech MX Master 3S", marca: "Logitech", categoria: "accesorios",
    precio: 99.99, activo: true, fecha_alta: new Date("2026-06-01"),
    variantes: [
      { sku: "MX3S-GRA", color: "Grafito", stock: NumberInt(25) },
      { sku: "MX3S-GRC", color: "Gris claro", stock: NumberInt(0) }
    ]
  }
]);
```

---

## Usuarios

5 usuarios con nombres inventados: 4 clientes y 1 administrador.

| `_id` | Nombre | Email | Rol | Fecha de registro |
|---|---|---|---|---|
| USR-01 | Laura Gómez | laura@ejemplo.com | cliente | 2025-11-02 |
| USR-02 | Pablo Ruiz | pablo@ejemplo.com | cliente | 2026-01-10 |
| USR-03 | Marta Sánchez | marta@ejemplo.com | cliente | 2026-02-21 |
| USR-04 | Diego Martín | diego@ejemplo.com | cliente | 2026-03-15 |
| USR-05 | Admin Tienda | admin@ejemplo.com | admin | 2025-09-01 |

```javascript
db.usuarios.insertMany([
  { _id: "USR-01", nombre: "Laura Gómez", email: "laura@ejemplo.com", rol: "cliente", fecha_registro: new Date("2025-11-02") },
  { _id: "USR-02", nombre: "Pablo Ruiz", email: "pablo@ejemplo.com", rol: "cliente", fecha_registro: new Date("2026-01-10") },
  { _id: "USR-03", nombre: "Marta Sánchez", email: "marta@ejemplo.com", rol: "cliente", fecha_registro: new Date("2026-02-21") },
  { _id: "USR-04", nombre: "Diego Martín", email: "diego@ejemplo.com", rol: "cliente", fecha_registro: new Date("2026-03-15") },
  { _id: "USR-05", nombre: "Admin Tienda", email: "admin@ejemplo.com", rol: "admin", fecha_registro: new Date("2025-09-01") }
]);
```

---

## Reseñas

Las 40 reseñas se generan con un bucle en lugar de escribirlas a mano:

- **Producto:** `i % 10` hace que se recorran los productos `PROD-001` a `PROD-010` cuatro veces, así que cada uno recibe **4 reseñas**. `PROD-011` y `PROD-012` se quedan sin reseñas.
- **Usuario:** `i % 4` reparte las reseñas entre los 4 clientes (`USR-01` a `USR-04`). El admin no escribe reseñas.
- **Estrellas:** se eligen del array `estrellas` con una fórmula que va variando el índice, y se guardan con `NumberInt()` porque el esquema exige un entero.
- **Comentario:** se van rotando los 6 comentarios del array.
- **Fecha:** días de septiembre de 2026. En `new Date(año, mes, día)` los meses empiezan en 0, por eso el 8 es septiembre.

```javascript
const comentarios = [
  "Muy buena calidad, lo recomiendo",
  "Llegó rápido y bien empaquetado",
  "Esperaba más por el precio",
  "Funciona perfecto",
  "La batería dura menos de lo que pone",
  "Relación calidad-precio muy buena"
];
const estrellas = [5, 4, 5, 3, 4, 2, 5, 4, 1, 5];
const resenas = [];

for (let i = 0; i < 40; i++) {
  const numProducto = (i % 10) + 1;               // va del 1 al 10 y vuelve a empezar
  resenas.push({
    producto_id: "PROD-" + String(numProducto).padStart(3, "0"),
    usuario_id: "USR-0" + ((i % 4) + 1),          // los 4 clientes
    estrellas: NumberInt(estrellas[(i * 3 + Math.floor(i / 10)) % 10]),
    comentario: comentarios[i % comentarios.length],
    fecha: new Date(2026, 8, 1 + (i % 30))        // septiembre de 2026 (los meses empiezan en 0)
  });
}
db.resenas.insertMany(resenas);
```

---

## Comprobación final

```javascript
print("Productos: " + db.productos.countDocuments());
print("Usuarios: " + db.usuarios.countDocuments());
print("Reseñas: " + db.resenas.countDocuments());
```

### Salida esperada

```text
Productos: 12
Usuarios: 5
Reseñas: 40
```

![Foto2.1](/PracticaUT2_01_Murillo_Alejandro/img/img2.1.png)
![Foto2.2](/PracticaUT2_01_Murillo_Alejandro/img/img2.2.png)
