# Datos de prueba

Todos los datos son **inventados para la práctica**. Los libros y autores son reales, pero las notas, préstamos, clubes y lectores me los he inventado. Los lectores no son personas reales y sus emails son del dominio `ejemplo.test`, que está reservado para pruebas. **No hay datos personales reales.**

Los datos van dentro de `scripts/02-carga-datos.cypher` (con `UNWIND`), así que no hay que importar ningún archivo aparte.

## Nodos (28)

| Etiqueta | Cuántos | Cuáles |
|---|---|---|
| Genero | 4 | Realismo mágico, Distopía, Fantasía, Misterio |
| Autor | 6 | García Márquez, Isabel Allende, George Orwell, Aldous Huxley, Patrick Rothfuss, Carlos Ruiz Zafón |
| Libro | 10 | LIB-01 a LIB-10 (2 de cada autor menos Allende y Huxley, con 1) |
| Lector | 6 | Lucas, Marta, Iván, Sara, Hugo, Carla |
| Club | 2 | Club de Lectura Cáceres (presencial) y Fantasía Online |

## Relaciones (62)

| Relación | Cuántas |
|---|---|
| LEE | 18 |
| ESCRIBE | 10 |
| DE_GENERO | 10 |
| MIEMBRO_DE | 6 |
| SIGUE_A | 5 |
| TIENE | 5 |
| PRESTA_A | 5 |
| LECTURA_DEL_MES | 3 |

## Cómo lo he montado para que las consultas den resultados

**Quién sigue a quién**
```
Lucas -> Marta -> Carla
Lucas -> Sara  -> Hugo
Iván  -> Lucas
```

**Cadenas de préstamo**
```
La sombra del viento:  Hugo -> Iván -> Marta   (no devuelto, lo tiene Marta)
1984:                  Iván -> Lucas -> Marta  (devuelto)
El temor de un hombre sabio:  Sara -> Carla    (devuelto)
```

**Gustos:** Lucas y Marta coinciden en dos libros con 4-5 estrellas (Cien años de soledad y 1984), así que Marta es la lectora más parecida a Lucas y sus libros salen los primeros en la recomendación.

**Clubes:** a Lucas le toca leer *La sombra del viento* en el Club de Cáceres y Hugo, que también es del club, la tiene en casa. Así la consulta P3b puede decirle a quién pedírsela.

**Camino más corto:** Carla quiere *La sombra del viento*, que la tiene Hugo. No se conocen, pero los dos están conectados con Sara (Sara le prestó un libro a Carla y Sara sigue a Hugo), así que el camino más corto es de 2 saltos.
