# Actividad
## 1.Definir el problema y los accesos (40 minutos)
Antes de crear colecciones, documenta:

## 1. El escenario elegido y sus usuarios.
1. El escenario es una tienda de electronica en la que los clientes buscan productos 

## 2. Al menos seis preguntas de negocio que la base de datos debe responder.
1. ¿Qué productos hay de una categoría, ordenados por precio?
2. ¿Qué productos de una marca cuestan entre un precio mínimo y uno máximo?
3. ¿Qué variantes tiene un producto y cuánto stock queda de cada una?
4. ¿Cuáles son las últimas reseñas de un producto?
5. ¿Cuál es la valoración media de cada producto?
6. ¿Qué productos tienen poco stock (menos de 5 unidades)?
7. ¿Qué productos contienen una palabra en su nombre (por ejemplo "inalámbrico")?

## 3. Los datos que se leen y escriben con mayor frecuencia.
- Catalogo de producto es decir si hay o no hay stock y nuevos productos que se añaden o se elimínan 

## 4. Una tabla que relacione cada pregunta con las colecciones, filtros, ordenación y paginación necesarios.

|preguntas|colecciones|filtros|ordenacion|paginacion|
|-----------|-------|-----------|----------|---------|
|¿Qué productos hay de una categoría, ordenados por precio?|productos|>precio|de mayor a menor|paginas
|¿Qué productos de una marca cuestan entre un precio mínimo y uno máximo?|marca - producto| >precio y <precio|de mayor a menor|paginas
|¿Qué variantes tiene un producto y cuánto stock queda de cada una?|productos|nombre del producto |alfabetica| paginas
|¿Cuáles son las últimas reseñas de un producto?|producto |reseñas|de mayor a menor rreseñas|paginas
|¿Cuál es la valoración media de cada producto?|producto|media de reseñas|de mayor a menor|paginas


## 5. Los requisitos de seguridad, privacidad, disponibilidad y crecimiento.
 1. seguridad autenticacion 2f de dos pasos
 2. privacidad , cumplir legal a trata con informacion personal y utilizar o pedir la que es necesaria 100%
 3. disponibilidad, Tolerancia a fallos y rebundacia
 
 4. Tener escalabilidad vertical y horizontal para que se lo mas barato y con la mayor posibiliada de escalibiliadad a lo largo del tiempo

