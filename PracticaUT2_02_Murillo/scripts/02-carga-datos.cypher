UNWIND [
  {id: "GEN-01", nombre: "Realismo mágico"},
  {id: "GEN-02", nombre: "Distopía"},
  {id: "GEN-03", nombre: "Fantasía"},
  {id: "GEN-04", nombre: "Misterio"}
] AS f
MERGE (g:Genero {id: f.id})
SET g.nombre = f.nombre;

UNWIND [
  {id: "AUT-01", nombre: "Gabriel García Márquez", pais: "CO"},
  {id: "AUT-02", nombre: "Isabel Allende",         pais: "CL"},
  {id: "AUT-03", nombre: "George Orwell",          pais: "GB"},
  {id: "AUT-04", nombre: "Aldous Huxley",          pais: "GB"},
  {id: "AUT-05", nombre: "Patrick Rothfuss",       pais: "US"},
  {id: "AUT-06", nombre: "Carlos Ruiz Zafón",      pais: "ES"}
] AS f
MERGE (a:Autor {id: f.id})
SET a.nombre = f.nombre,
    a.pais   = f.pais;

UNWIND [
  {id: "LIB-01", titulo: "Cien años de soledad",             anio: 1967, paginas: 471},
  {id: "LIB-02", titulo: "Crónica de una muerte anunciada",  anio: 1981, paginas: 128},
  {id: "LIB-03", titulo: "La casa de los espíritus",         anio: 1982, paginas: 512},
  {id: "LIB-04", titulo: "1984",                             anio: 1949, paginas: 352},
  {id: "LIB-05", titulo: "Rebelión en la granja",            anio: 1945, paginas: 144},
  {id: "LIB-06", titulo: "Un mundo feliz",                   anio: 1932, paginas: 288},
  {id: "LIB-07", titulo: "El nombre del viento",             anio: 2007, paginas: 880},
  {id: "LIB-08", titulo: "El temor de un hombre sabio",      anio: 2011, paginas: 1200},
  {id: "LIB-09", titulo: "La sombra del viento",             anio: 2001, paginas: 576},
  {id: "LIB-10", titulo: "El juego del ángel",               anio: 2008, paginas: 672}
] AS f
MERGE (b:Libro {id: f.id})
SET b.titulo  = f.titulo,
    b.anio    = f.anio,
    b.paginas = f.paginas;

UNWIND [
  {id: "LEC-01", nombre: "Lucas", ciudad: "Cáceres", email: "lucas@ejemplo.test"},
  {id: "LEC-02", nombre: "Marta", ciudad: "Cáceres", email: "marta@ejemplo.test"},
  {id: "LEC-03", nombre: "Iván",  ciudad: "Mérida",  email: "ivan@ejemplo.test"},
  {id: "LEC-04", nombre: "Sara",  ciudad: "Badajoz", email: "sara@ejemplo.test"},
  {id: "LEC-05", nombre: "Hugo",  ciudad: "Cáceres", email: "hugo@ejemplo.test"},
  {id: "LEC-06", nombre: "Carla", ciudad: "Plasencia", email: "carla@ejemplo.test"}
] AS f
MERGE (l:Lector {id: f.id})
SET l.nombre         = f.nombre,
    l.ciudad         = f.ciudad,
    l.email          = f.email,
    l.perfil_privado = false;

UNWIND [
  {id: "CLU-01", nombre: "Club de Lectura Cáceres", ciudad: "Cáceres", online: false},
  {id: "CLU-02", nombre: "Fantasía Online",         ciudad: null,      online: true}
] AS f
MERGE (c:Club {id: f.id})
SET c.nombre = f.nombre,
    c.ciudad = f.ciudad,
    c.online = f.online;

UNWIND [
  ["AUT-01","LIB-01"], ["AUT-01","LIB-02"], ["AUT-02","LIB-03"],
  ["AUT-03","LIB-04"], ["AUT-03","LIB-05"], ["AUT-04","LIB-06"],
  ["AUT-05","LIB-07"], ["AUT-05","LIB-08"], ["AUT-06","LIB-09"],
  ["AUT-06","LIB-10"]
] AS f
MATCH (a:Autor {id: f[0]}), (b:Libro {id: f[1]})
MERGE (a)-[:ESCRIBE]->(b);

UNWIND [
  ["LIB-01","GEN-01"], ["LIB-02","GEN-01"], ["LIB-03","GEN-01"],
  ["LIB-04","GEN-02"], ["LIB-05","GEN-02"], ["LIB-06","GEN-02"],
  ["LIB-07","GEN-03"], ["LIB-08","GEN-03"],
  ["LIB-09","GEN-04"], ["LIB-10","GEN-04"]
] AS f
MATCH (b:Libro {id: f[0]}), (g:Genero {id: f[1]})
MERGE (b)-[:DE_GENERO]->(g);

UNWIND [
  {l: "LEC-01", b: "LIB-01", estado: "leido",   nota: 5},
  {l: "LEC-01", b: "LIB-04", estado: "leido",   nota: 5},
  {l: "LEC-01", b: "LIB-07", estado: "leido",   nota: 4},
  {l: "LEC-02", b: "LIB-01", estado: "leido",   nota: 5},
  {l: "LEC-02", b: "LIB-04", estado: "leido",   nota: 4},
  {l: "LEC-02", b: "LIB-06", estado: "leido",   nota: 5},
  {l: "LEC-02", b: "LIB-03", estado: "leido",   nota: 5},
  {l: "LEC-02", b: "LIB-09", estado: "leyendo", nota: null},
  {l: "LEC-03", b: "LIB-04", estado: "leido",   nota: 5},
  {l: "LEC-03", b: "LIB-05", estado: "leido",   nota: 4},
  {l: "LEC-03", b: "LIB-09", estado: "leido",   nota: 5},
  {l: "LEC-04", b: "LIB-07", estado: "leido",   nota: 5},
  {l: "LEC-04", b: "LIB-08", estado: "leido",   nota: 5},
  {l: "LEC-04", b: "LIB-10", estado: "leido",   nota: 4},
  {l: "LEC-05", b: "LIB-09", estado: "leido",   nota: 4},
  {l: "LEC-05", b: "LIB-02", estado: "leido",   nota: 3},
  {l: "LEC-06", b: "LIB-03", estado: "leido",   nota: 4},
  {l: "LEC-06", b: "LIB-08", estado: "leido",   nota: 5}
] AS f
MATCH (l:Lector {id: f.l}), (b:Libro {id: f.b})
MERGE (l)-[r:LEE]->(b)
SET r.estado     = f.estado,
    r.puntuacion = f.nota;

UNWIND [
  ["LEC-01","LEC-02","2024-02-01"],
  ["LEC-01","LEC-04","2024-09-15"],
  ["LEC-02","LEC-06","2025-01-10"],
  ["LEC-04","LEC-05","2025-03-22"],
  ["LEC-03","LEC-01","2025-04-30"]
] AS f
MATCH (a:Lector {id: f[0]}), (b:Lector {id: f[1]})
MERGE (a)-[r:SIGUE_A]->(b)
SET r.desde = date(f[2]);

UNWIND [
  ["LEC-01","CLU-01","2024-10-01"], ["LEC-02","CLU-01","2023-09-15"],
  ["LEC-05","CLU-01","2025-02-01"], ["LEC-01","CLU-02","2025-06-01"],
  ["LEC-04","CLU-02","2024-01-20"], ["LEC-06","CLU-02","2024-11-11"]
] AS f
MATCH (l:Lector {id: f[0]}), (c:Club {id: f[1]})
MERGE (l)-[r:MIEMBRO_DE]->(c)
SET r.desde = date(f[2]);

UNWIND [
  ["CLU-01","LIB-01","2026-09"],
  ["CLU-01","LIB-09","2026-10"],
  ["CLU-02","LIB-08","2026-10"]
] AS f
MATCH (c:Club {id: f[0]}), (b:Libro {id: f[1]})
MERGE (c)-[r:LECTURA_DEL_MES]->(b)
SET r.mes = f[2];

UNWIND [
  ["LEC-05","LIB-09","bueno"], ["LEC-03","LIB-04","usado"],
  ["LEC-04","LIB-08","nuevo"], ["LEC-02","LIB-06","bueno"],
  ["LEC-02","LIB-03","usado"]
] AS f
MATCH (l:Lector {id: f[0]}), (b:Libro {id: f[1]})
MERGE (l)-[r:TIENE]->(b)
SET r.estado_copia = f[2];

UNWIND [
  {de: "LEC-05", a: "LEC-03", libro: "LIB-09", fecha: "2026-02-01", devuelto: false},
  {de: "LEC-03", a: "LEC-02", libro: "LIB-09", fecha: "2026-04-10", devuelto: false},
  {de: "LEC-04", a: "LEC-06", libro: "LIB-08", fecha: "2025-11-03", devuelto: true},
  {de: "LEC-03", a: "LEC-01", libro: "LIB-04", fecha: "2025-05-12", devuelto: true},
  {de: "LEC-01", a: "LEC-02", libro: "LIB-04", fecha: "2025-07-20", devuelto: true}
] AS f
MATCH (a:Lector {id: f.de}), (b:Lector {id: f.a})
MERGE (a)-[p:PRESTA_A {libro: f.libro}]->(b)
SET p.fecha    = date(f.fecha),
    p.devuelto = f.devuelto;

MATCH (n) RETURN count(n) AS total_nodos;

MATCH ()-[r]->() RETURN count(r) AS total_relaciones;

MATCH (n) RETURN labels(n)[0] AS etiqueta, count(*) AS total ORDER BY total DESC;

MATCH ()-[r]->() RETURN type(r) AS relacion, count(*) AS total ORDER BY total DESC;

MATCH (n) WHERE size(labels(n)) = 0 RETURN count(n) AS nodos_vacios;
