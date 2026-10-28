# 04 · Copias de seguridad, restauración y permisos

## 1. Hacer la copia (dump)

El dump es un archivo con toda la base: nodos, relaciones, índices y restricciones. En Neo4j 5 la base tiene que estar **parada** para hacerlo.

### Desde Neo4j Desktop (lo que he hecho yo)

1. Paro la base con **Stop**.
2. En los tres puntos `...` de la base → **Dump**.
3. Me deja el archivo `.dump` en el apartado *File* del proyecto. Lo copio a otra carpeta o a la nube por si se rompe el ordenador.

### Desde la terminal

En Neo4j Desktop: `...` → **Open → Terminal**, o en un servidor:

```bash
neo4j stop

# Copia completa de la base "neo4j"
neo4j-admin database dump neo4j --to-path=/var/backups/pasapagina/

neo4j start
```

Sale el archivo `/var/backups/pasapagina/neo4j.dump`. Lo suyo es renombrarlo con la fecha (`neo4j_2026-10-27.dump`) y tener varias copias en sitios distintos.

### En Neo4j Aura

Aura hace copias automáticas cada día. También se puede hacer una a mano desde la consola: instancia → **Snapshots** → *Take snapshot*, y descargarla con *Export*.

## 2. Restaurar

### Neo4j Desktop

Arrastro el `.dump` al proyecto → `...` → **Create new DBMS from dump** (o *Import into existing DBMS*).

### Terminal

```bash
neo4j stop

# --from-path es la CARPETA donde está el neo4j.dump
neo4j-admin database load neo4j --from-path=/var/backups/pasapagina/ --overwrite-destination=true

neo4j start
```

### Comprobar que ha salido bien

```cypher
MATCH (n) RETURN count(n);        // 28 (si no he lanzado aún el script 03)
MATCH ()-[r]->() RETURN count(r); // 62
SHOW CONSTRAINTS;                 // las 5 restricciones
```

## 3. Usuarios y permisos

Sigo el principio de **mínimo privilegio**: cada uno solo puede hacer lo que necesita.

> Esto se lanza en la base `system` (en Neo4j Browser escribir antes `:use system`). Funciona en Neo4j Desktop. En **Aura Free no se pueden crear usuarios**, así que ahí solo queda documentado.
>
> Las contraseñas son de ejemplo: **no entrego contraseñas reales**.

```cypher
:use system

// --- App móvil: solo lectura y SIN ver los emails de los lectores ---
CREATE ROLE app_lectura IF NOT EXISTS;
GRANT ACCESS ON DATABASE neo4j TO app_lectura;
GRANT MATCH {*} ON GRAPH neo4j TO app_lectura;
DENY READ {email} ON GRAPH neo4j NODES Lector TO app_lectura;

CREATE USER app_pasapagina IF NOT EXISTS
  SET PASSWORD '<CAMBIAR>' CHANGE REQUIRED;
GRANT ROLE app_lectura TO app_pasapagina;

// --- Moderador del catálogo: puede dar de alta libros y autores ---
CREATE USER moderador IF NOT EXISTS
  SET PASSWORD '<CAMBIAR>' CHANGE REQUIRED;
GRANT ROLE editor TO moderador;

// --- Administrador: todo (índices, backups, usuarios) ---
CREATE USER admin_pasapagina IF NOT EXISTS
  SET PASSWORD '<CAMBIAR>' CHANGE REQUIRED;
GRANT ROLE admin TO admin_pasapagina;

SHOW USERS;
SHOW ROLE app_lectura PRIVILEGES;
```

| Usuario | Rol | Puede | No puede |
|---|---|---|---|
| `app_pasapagina` | `app_lectura` | Leer libros, lectores, préstamos… | Escribir, ver emails, tocar índices |
| `moderador` | `editor` | Leer y escribir datos | Crear índices o usuarios |
| `admin_pasapagina` | `admin` | Todo | — |

La app también tiene que guardar cuándo alguien puntúa un libro o presta uno. Para eso pondría un rol aparte que solo pueda crear esas relaciones:

```cypher
CREATE ROLE app_escritura IF NOT EXISTS;
GRANT CREATE ON GRAPH neo4j RELATIONSHIPS LEE, PRESTA_A TO app_escritura;
GRANT SET PROPERTY {estado, puntuacion, fecha, devuelto} ON GRAPH neo4j RELATIONSHIPS LEE, PRESTA_A TO app_escritura;
```

Y las conexiones desde la app irían cifradas (`neo4j+s://`).
