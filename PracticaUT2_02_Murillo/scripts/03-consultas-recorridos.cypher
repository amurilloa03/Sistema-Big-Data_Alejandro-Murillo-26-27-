PROFILE
MATCH (b:Libro {titulo: "1984"})
RETURN b.titulo, b.anio, b.paginas;

MATCH (a:Autor {nombre: "George Orwell"})-[:ESCRIBE]->(b:Libro)
OPTIONAL MATCH (b)-[:DE_GENERO]->(g:Genero)
OPTIONAL MATCH (:Lector)-[r:LEE]->(b)
RETURN b.titulo                    AS libro,
       b.anio                      AS anio,
       b.paginas                   AS paginas,
       g.nombre                    AS genero,
       round(avg(r.puntuacion), 1) AS nota_media,
       count(r)                    AS lectores
ORDER BY nota_media DESC;

MATCH (a:Autor {nombre: "George Orwell"})-[e:ESCRIBE]->(b:Libro)-[d:DE_GENERO]->(g:Genero)
RETURN a, e, b, d, g;

MATCH (yo:Lector {id: "LEC-01"})-[r1:LEE]->(b:Libro)<-[r2:LEE]-(otro:Lector)
WHERE r1.puntuacion >= 4 AND r2.puntuacion >= 4
WITH yo, otro, count(b) AS libros_en_comun
MATCH (otro)-[r3:LEE]->(rec:Libro)
WHERE r3.puntuacion >= 4
  AND NOT EXISTS { (yo)-[:LEE]->(rec) }
RETURN rec.titulo                AS libro_recomendado,
       collect(otro.nombre)      AS recomendado_por,
       sum(libros_en_comun)      AS afinidad
ORDER BY afinidad DESC, libro_recomendado;

MATCH (yo:Lector {id: "LEC-01"})-[r1:LEE]->(:Libro)<-[r2:LEE]-(otro:Lector)
WHERE r1.puntuacion >= 4 AND r2.puntuacion >= 4
MATCH (otro)-[r3:LEE]->(:Libro)<-[:ESCRIBE]-(autor:Autor)
WHERE r3.puntuacion >= 4
  AND NOT EXISTS { (yo)-[:LEE]->(:Libro)<-[:ESCRIBE]-(autor) }
RETURN autor.nombre AS autor_que_te_puede_gustar,
       collect(DISTINCT otro.nombre) AS porque_le_gusta_a;

MATCH (yo:Lector {id: "LEC-01"})-[:SIGUE_A]->(amigo:Lector)-[r:LEE]->(b:Libro)
WHERE r.puntuacion >= 4
  AND NOT EXISTS { (yo)-[:LEE]->(b) }
RETURN b.titulo        AS libro,
       amigo.nombre    AS lo_recomienda,
       r.puntuacion    AS estrellas,
       EXISTS { (amigo)-[:TIENE]->(b) } AS te_lo_puede_prestar
ORDER BY estrellas DESC, libro;

MATCH (yo:Lector {id: "LEC-01"})-[:MIEMBRO_DE]->(c:Club)-[m:LECTURA_DEL_MES]->(b:Libro)
WHERE NOT EXISTS { (yo)-[:LEE]->(b) }
OPTIONAL MATCH (c)<-[:MIEMBRO_DE]-(compi:Lector)-[:TIENE]->(b)
WHERE compi <> yo
RETURN c.nombre AS club,
       m.mes    AS mes,
       b.titulo AS libro,
       collect(compi.nombre) AS te_lo_puede_prestar;

MATCH camino = (origen:Lector)-[:PRESTA_A*1..5]->(actual:Lector)
WHERE all(p IN relationships(camino) WHERE p.libro = "LIB-09")
  AND NOT EXISTS { (:Lector)-[:PRESTA_A {libro: "LIB-09"}]->(origen) }
  AND NOT EXISTS { (actual)-[:PRESTA_A {libro: "LIB-09"}]->(:Lector) }
RETURN [n IN nodes(camino) | n.nombre]          AS cadena_de_prestamo,
       [p IN relationships(camino) | p.fecha]    AS fechas,
       length(camino)                            AS num_prestamos,
       actual.nombre                             AS lo_tiene_ahora;

MATCH camino = (:Lector)-[:PRESTA_A*1..5]->(:Lector)
WHERE all(p IN relationships(camino) WHERE p.libro = "LIB-09")
RETURN camino;

MATCH (yo:Lector {id: "LEC-06"})
MATCH (:Libro {id: "LIB-09"})<-[:TIENE]-(dueno:Lector)
MATCH camino = shortestPath((yo)-[:SIGUE_A|PRESTA_A*..6]-(dueno))
RETURN dueno.nombre                       AS lo_tiene,
       [n IN nodes(camino) | n.nombre]    AS cadena_de_contactos,
       length(camino)                     AS saltos;

MATCH (yo:Lector {id: "LEC-06"}), (dueno:Lector {id: "LEC-05"})
MATCH camino = shortestPath((yo)-[:SIGUE_A|PRESTA_A*..6]-(dueno))
RETURN camino;

MATCH (yo:Lector {id: "LEC-01"}), (b:Libro {id: "LIB-08"})
MERGE (yo)-[r:LEE]->(b)
ON CREATE SET r.fecha_inicio = date()
SET r.estado     = "leido",
    r.puntuacion = 5,
    r.fecha_fin  = date()
RETURN yo.nombre AS lector, b.titulo AS libro, r.estado AS estado, r.puntuacion AS estrellas;

MATCH (de:Lector {id: "LEC-02"}), (a:Lector {id: "LEC-01"}), (b:Libro {id: "LIB-06"})
MERGE (de)-[p:PRESTA_A {libro: b.id}]->(a)
ON CREATE SET p.fecha    = date(),
              p.devuelto = false,
              b.veces_prestado = coalesce(b.veces_prestado, 0) + 1
RETURN de.nombre AS presta, a.nombre AS recibe, b.titulo AS libro,
       p.fecha AS fecha, b.veces_prestado AS veces_prestado;

MATCH (:Lector {id: "LEC-02"})-[p:PRESTA_A {libro: "LIB-06"}]->(:Lector {id: "LEC-01"})
SET p.devuelto = true, p.fecha_devolucion = date()
RETURN p;

MATCH (:Lector)-[r:LEE]->(:Libro)-[:DE_GENERO]->(g:Genero)
WHERE r.puntuacion IS NOT NULL
RETURN g.nombre AS genero,
       round(avg(r.puntuacion), 2) AS nota_media,
       count(r) AS valoraciones
ORDER BY nota_media DESC;

MATCH ()-[p:PRESTA_A]->()
MATCH (b:Libro {id: p.libro})
RETURN b.titulo AS libro, count(p) AS veces_prestado
ORDER BY veces_prestado DESC;

MERGE (u:Lector {id: "LEC-99"}) SET u.nombre = "Usuario Baja", u.email = "baja@ejemplo.test";

MATCH (u:Lector {id: "LEC-99"}), (b:Libro {id: "LIB-01"})
MERGE (u)-[:LEE {estado: "leido"}]->(b);

MATCH (u:Lector {id: "LEC-99"}) DETACH DELETE u;

MATCH (u:Lector {id: "LEC-99"}) RETURN count(u) AS tiene_que_ser_0;

MATCH (n)
OPTIONAL MATCH (n)-[r]-(m)
RETURN n, r, m;

CALL db.schema.visualization();
