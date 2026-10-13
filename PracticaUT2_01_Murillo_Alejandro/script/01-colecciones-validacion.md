# 01 - Crear la base de datos y las colecciones con validación

Script para MongoDB que crea la base de datos `tienda_electronica` con tres colecciones (`productos`, `usuarios` y `resenas`), cada una con su esquema de validación `$jsonSchema`, y después lanza unas pruebas para comprobar que la validación rechaza datos incorrectos.

---

## Preparar la base de datos

Se selecciona la base de datos y se borra por si ya existía, para empezar desde cero.

```javascript
db = db.getSiblingDB("tienda_electronica");
db.dropDatabase();
```

---

## Colección `productos`

| Campo | Tipo | Reglas |
|---|---|---|
| `_id` | string | Formato `PROD-000` (3 dígitos) |
| `nombre` | string | Mínimo 3 caracteres |
| `marca` | string | — |
| `categoria` | enum | `moviles`, `portatiles`, `audio`, `televisores`, `accesorios` |
| `precio` | double / int | Mínimo 0 |
| `activo` | bool | — |
| `fecha_alta` | date | Opcional |
| `variantes` | array | Mínimo 1 elemento; cada uno con `sku` y `stock` (int ≥ 0) obligatorios, `color` y `capacidad` opcionales |

Campos obligatorios: `_id`, `nombre`, `marca`, `categoria`, `precio`, `activo`, `variantes`.

```javascript
db.createCollection("productos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "nombre", "marca", "categoria", "precio", "activo", "variantes"],
      properties: {
        _id: { bsonType: "string", pattern: "^PROD-[0-9]{3}$" },
        nombre: { bsonType: "string", minLength: 3 },
        marca: { bsonType: "string" },
        categoria: { enum: ["moviles", "portatiles", "audio", "televisores", "accesorios"] },
        precio: { bsonType: ["double", "int"], minimum: 0 },
        activo: { bsonType: "bool" },
        fecha_alta: { bsonType: "date" },
        variantes: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["sku", "stock"],
            properties: {
              sku: { bsonType: "string" },
              color: { bsonType: "string" },
              capacidad: { bsonType: "string" },
              stock: { bsonType: "int", minimum: 0 }
            }
          }
        }
      }
    }
  }
});
```

---

## Colección `usuarios`

| Campo | Tipo | Reglas |
|---|---|---|
| `_id` | string | Formato `USR-00` (2 dígitos) |
| `nombre` | string | — |
| `email` | string | Debe tener `@` y un dominio con extensión de al menos 2 letras |
| `rol` | enum | `cliente`, `admin` |
| `fecha_registro` | date | Opcional |

Campos obligatorios: `_id`, `nombre`, `email`, `rol`.

```javascript
db.createCollection("usuarios", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "nombre", "email", "rol"],
      properties: {
        _id: { bsonType: "string", pattern: "^USR-[0-9]{2}$" },
        nombre: { bsonType: "string" },
        email: { bsonType: "string", pattern: "^[^@]+@[^@]+\\.[a-z]{2,}$" },
        rol: { enum: ["cliente", "admin"] },
        fecha_registro: { bsonType: "date" }
      }
    }
  }
});
```

---

## Colección `resenas`

| Campo | Tipo | Reglas |
|---|---|---|
| `producto_id` | string | — |
| `usuario_id` | string | — |
| `estrellas` | int | Entre 1 y 5 |
| `comentario` | string | Máximo 500 caracteres, opcional |
| `fecha` | date | — |

Campos obligatorios: `producto_id`, `usuario_id`, `estrellas`, `fecha`.

```javascript
db.createCollection("resenas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["producto_id", "usuario_id", "estrellas", "fecha"],
      properties: {
        producto_id: { bsonType: "string" },
        usuario_id: { bsonType: "string" },
        estrellas: { bsonType: "int", minimum: 1, maximum: 5 },
        comentario: { bsonType: "string", maxLength: 500 },
        fecha: { bsonType: "date" }
      }
    }
  }
});

print("Colecciones creadas: " + db.getCollectionNames());
```

---

## Pruebas de validación

Cada prueba intenta insertar un documento que **no** cumple el esquema. Si la validación funciona, el `insertOne` lanza una excepción y se imprime `OK`.

| Prueba | Colección | Qué falla |
|---|---|---|
| 1 | `productos` | Precio negativo y array `variantes` vacío |
| 2 | `productos` | Categoría `electrodomesticos`, que no está en el enum |
| 3 | `resenas` | 7 estrellas (máximo 5) |
| 4 | `usuarios` | Email sin `@` |

```javascript
print("Pruebas de validación:");

try {
  db.productos.insertOne({ _id: "PROD-999", nombre: "Producto malo", marca: "X", categoria: "moviles", precio: -10, activo: true, variantes: [] });
  print("ERROR: se ha guardado un producto con precio negativo");
} catch (e) {
  print("OK - rechazado producto con precio negativo y sin variantes");
}

try {
  db.productos.insertOne({ _id: "PROD-998", nombre: "Nevera", marca: "X", categoria: "electrodomesticos", precio: 300, activo: true, variantes: [{ sku: "NEV-1", stock: NumberInt(3) }] });
  print("ERROR: se ha guardado una categoría que no existe");
} catch (e) {
  print("OK - rechazada categoría que no está en la lista");
}

try {
  db.resenas.insertOne({ producto_id: "PROD-001", usuario_id: "USR-01", estrellas: NumberInt(7), fecha: new Date() });
  print("ERROR: se ha guardado una reseña de 7 estrellas");
} catch (e) {
  print("OK - rechazada reseña con 7 estrellas (máximo 5)");
}

try {
  db.usuarios.insertOne({ _id: "USR-99", nombre: "Prueba", email: "correo-sin-arroba", rol: "cliente" });
  print("ERROR: se ha guardado un email sin formato correcto");
} catch (e) {
  print("OK - rechazado email con formato incorrecto");
}
```

### Salida esperada

```text
Colecciones creadas: productos,resenas,usuarios
Pruebas de validación:
OK - rechazado producto con precio negativo y sin variantes
OK - rechazada categoría que no está en la lista
OK - rechazada reseña con 7 estrellas (máximo 5)
OK - rechazado email con formato incorrecto
```
![Foto1.1](/PracticaUT2_01_Murillo_Alejandro/img/img1.1.png)
