# 1. Definir el Problema y los Accesos
## 1.1. Escenarios Elegidos y Usuarios

Escenario: Plataforma tipo spotify , con un catalogo de canciones y artistas , albunes , generos y listas de reproduccion 

# Usuarios

Oyentes: Personas que escuchan musica y siguen a sus artistas o dan like a canciones

Cantantes : Sube y publica sus canciones , añade Titulo ,k duracion , genero y colaboracion 

Analisis : Featuring entra cantantes y top tendencia y albunes

Motor de Recomendaciones : Artista afines a tus gustos y recomendaciones de canciones que se asemeja a las que escuchas 

## 1.2. Seis Preguntas que la base de datos tiene que responder 

1. Canciones que tiene un artistas ? (Con todos sus campos )

2. Informacion del usuario , canciones que les gustan y escucha mas 

3. Cantantes que han colaborar con otros

4. Una red de saltos que un usuario te recominedes 2 o 3 artistas que sigue a los que tu sigues (a:Artista)-[:SIGUE_CON*2..3]->(a)

5. Camino mas corto que uno a dos artistas (shortestPath)

6. Like de canciones que escucha cada usuario y como añadirlo con set y contar con merge


## 1.3 Datos con Mayor Frecuencias de Lectura y Escritura

Lecturas: Generacion de una interfaz para ti , ver que estan escuchando en tiempo real 

Escritura: Canciones guardadas cada vez qeu das like y contador de escucha y nuevas relaciones entre usuario y canciones o artista

## 1.4 Requisitos de Seguridad, Privacidad , Disponibilidad y Crecimiento



# 2.Diseñar el Grafo de Nodos y Relaciones

## 2.1 Etiquetas de Nodos y Tipos de Relaciones
Etiquetas de Nodos (Labels):
:Usuario: Cuentas de oyentes (id, nombre, email, pais, cuenta_premium).
:Cancion: Temas musicales (id, titulo, duracion_seg, lanzamiento, reproducciones_globales).
:Artista: Cantantes, compositores o bandas (id, nombre, oyentes_mensuales, pais_origen).
:Genero: Estilos musicales (id, nombre).
:Playlist: Listas de canciones creadas por usuarios o la plataforma (id, nombre, es_publica).

## 2.2 Tipos de Relaciones(Relationships)
(:Usuario)-[:SIGUE_A {desde: "2024-01-15"}]->(:Usuario)
(:Usuario)-[:ESCUCHA {reproducciones: 52, favorito: true, ultima_vez: "2026-03-01"}]->(:Cancion)
(:Artista)-[:INTERPRETA {rol: "principal"}]->(:Cancion)
(:Cancion)-[:PERTENECE_A]->(:Genero)
(:Playlist)-[:CONTIENE_PISTA {orden: 1, anadida_el: "2026-02-10"}]->(:Cancion)
(:Usuario)-[:SIGUE_A]->(:Artista)

## 2.3 Justificacion tecnica frente a SQL

Para hacer consultas de relaciones en sql se necesita que en una consulta que requiere 2 salto en entre tablas tenga que aparecer todas las tablas que tiene algo que ver en cambio NEO puede saltarse por los punteros de memoria directos sin meter todas las tablas y en menos tiempo 


## 2.4 Estrategia de Identificadores y Propiedad en Relaciones

- Identificadores unicos y legibles como id:cliente001

- Propiedades en las relaciones [Perteneces a] guarda la fecha , el genero 

## 2.5 Limites del Modelo 

- Antipatrón Supernodos
En genero va a ver muchas canciones relacionadas por ejemplo con trap , por eso las consultas parte de un oyente o artista para que no vaya lenta y no pete la base de datos sacando como 300.000 datos de golpe

- Profundidad de saltos acotada
Se acota la maxima de saltos que se puede saltar , por ejemplo  [Like 1 * 3]


# 3 Implementar Restricciones






