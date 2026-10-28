# Evidencias

Capturas hechas en Neo4j Aura (5.27-aura), en orden de ejecución:

| Archivo | Qué se ve |
|---|---|
| `00-version.png` | Versión de Neo4j → 5.27-aura Enterprise |
| `01-constraints.png` | `SHOW CONSTRAINTS` → 5 restricciones (Autor, Club, Genero, Lector, Libro) |
| `02-indexes.png` | `SHOW INDEXES` → 11 índices (mis 4 + los de las restricciones + 2 de Neo4j) |
| `03a-total-nodos.png` | Después de la carga → 28 nodos |
| `03b-total-relaciones.png` | Después de la carga → 62 relaciones |
| `03c-nodos-vacios.png` | Nodos sin etiqueta → 0 |
| `04-grafo-completo.png` | Todo el grafo: 28 nodos y 62 relaciones por tipo |
| `05-profile.png` | `PROFILE` → NodeIndexSeek con el índice de título, 4 accesos a la base de datos |
| `06-p1-libros-autor.png` | P1 · libros de Orwell con nota media (1984 → 4.7, Rebelión → 4.0) |
| `07-p2-afinidad.png` | P2 · recomendación por afinidad para Lucas |
| `08a-p3-gente-que-sigo.png` | P3 · libros de la gente que sigo y si me los pueden prestar |
| `08b-p3-clubes.png` | P3 · lectura del mes de mis clubes y quién la tiene |
| `09a-p4-cadena-prestamo.png` | P4 · cadena de préstamo Hugo → Iván → Marta |
| `09b-p4-cadena-grafo.png` | P4 · la misma cadena en el grafo |
| `10a-p5-shortestpath.png` | P5 · camino más corto Carla → Sara → Hugo (2 saltos) |
| `10b-p5-shortestpath-grafo.png` | P5 · el mismo camino en el grafo |
| `11-p6-merge-set.png` | P6 · MERGE + SET (nota de Lucas y préstamo de Marta, `veces_prestado` = 1) |
| `12-backup-snapshot.png` | Snapshot de Aura (On Demand + copia Scheduled automática) |
