# Tarea de Laboratorio 3: Neo4J

**Grafo de Explicabilidad para Auditoría de Clasificación Normativa**

INF-325 Bases de Datos Avanzadas
Profesor: Mauricio Figueroa Colarte
05 de junio de 2026

## 1. Contexto

Una empresa Fintech necesita apoyar su proceso de cumplimiento normativo tributario mediante el análisis de resoluciones y circulares publicadas por el Servicio de Impuestos Internos, SII. Para ello, dispone de un dataset de normativas previamente analizadas por un agente IA normativo, el cual utilizó procesamiento de lenguaje natural y RAG para clasificar cada normativa como **Relevante** o **No Relevante**.

La clasificación indica si la normativa podría afectar o no el cumplimiento normativo del negocio. Sin embargo, una decisión automatizada no debe aceptarse sin revisión: el equipo humano de cumplimiento necesita comprender por qué la IA asignó una clasificación, qué evidencia respalda esa decisión y si la explicación entregada es válida para el negocio.

## 2. Dataset disponible

Se entrega el archivo `normativas_clasificadas_IA.csv`. Todo el laboratorio debe desarrollarse a partir de este dataset; no se requiere buscar normativas adicionales ni implementar una IA nueva.

**Tabla 1: Metadatos de las normativas**

| Campo | Descripción |
| --- | --- |
| name | Nombre de la normativa |
| description | Descripción breve de la normativa |
| fuente | Fuente asociada |
| url | Enlace al documento original |
| tipo_documento | Circular o Resolución |
| cuerpo | Texto de la normativa |
| relevancia | Clasificación entregada por la IA |
| explicacion | Explicación generada por la IA |

## 3. Objetivos

### 3.2 Objetivos específicos

1. Generar un grafo en Neo4j a partir del dataset entregado.
2. Representar normativas, clasificaciones, explicaciones, fuentes, tipos documentales, reglas de negocio y evidencias textuales.
3. Usar relaciones y etiquetas de nodos para organizar la información del grafo.
4. Consultar el grafo para explicar por qué una normativa fue clasificada como relevante o no relevante.
5. Determinar si la explicación de la IA es válida para el negocio según reglas preestablecidas.
6. Identificar normativas que requieren revisión humana por baja explicabilidad, falta de evidencia o posible contradicción entre clasificación y reglas de negocio.

## 4. Requisitos

**1. Construcción y relaciones mínimas del grafo.** Cada grupo deberá construir un grafo en Neo4j desde el archivo CSV. El grafo debe representar: Normativa, Clasificación IA, Explicación IA, Agente IA, Fuente, Tipo de documento, Regla de negocio, Evidencia textual y Auditoría humana. Además, debe permitir recorrer la decisión de la IA mediante relaciones entre normativa, clasificación, explicación, reglas, evidencia y revisión humana.

> Ruta conceptual esperada: Normativa → Clasificación IA → Explicación IA → Regla de negocio → Evidencia textual → Auditoría humana.

*Figura 1: Ejemplo simplificado de grafo explicabilidad normativa*

**Tabla 2: Criterios de Relevancia según normativas**

| Referencia normativa relevante | Glosa esperada / aproximada |
| --- | --- |
| Resolución Exenta N° 176 de 2020 | Resolución 176 de 2020 |
| Resolución Exenta N° 76 de 2021 | Resolución 76 de 2021 |
| Resolución Exenta N° 79 de 2025 | Resolución 79 de 2025 |
| Resolución N° 59 de 2025 | Resolución 59 de 2025 |
| Circular N° 38 de 2025 | Circular 38 de 2025 |
| Artículo 68 del Código Tributario | Artículo 68 del Código Tributario |

**2. Uso obligatorio de etiquetas en nodos.** Las normativas deben etiquetarse para facilitar consultas del grafo.

Etiquetas esperadas → `:Normativa`, `:Circular`, `:Resolucion`, `:Relevante`, `:NoRelevante`, `:ExplicacionValida`, `:ExplicacionDebil`, `:RequiereRevision` y `:Auditada`.

**Tabla 3: Criterios de Relevancia según palabras claves**

| Palabra clave | Regla asociada |
| --- | --- |
| boleta | Contiene "boleta" |
| comprobante electrónico | Contiene "comprobante electrónico" |
| registro de compra | Contiene "registro de compra" |
| registro de venta | Contiene "registro de venta" |
| cumplimiento tributario | Contiene "cumplimiento tributario" |
| inicio de actividades | Contiene "inicio de actividades" |
| medios de pago electrónicos | Contiene "medios de pago electrónicos" |
| POS | Contiene "POS" |
| P.O.S | Contiene "P.O.S" |
| puntos de venta | Contiene "puntos de venta" |
| operadores y administradores | Contiene "operadores y administradores" |
| comercio electrónico | Contiene "comercio electrónico" |

**4. Consultas de explicabilidad obligatorias.**

1. **Consulta de clasificación general:** visualizar normativas Relevantes y No Relevantes con nombre, tipo documental, fuente, descripción y explicación IA.
2. **Consulta explicativa de una normativa específica:** mostrar clasificación IA, explicación, reglas activadas y evidencia textual asociada.
3. **Consulta de normativas relevantes con respaldo de negocio:** identificar normativas Relevantes que activan reglas de negocio y cuentan con evidencia textual.
4. **Consulta de posibles inconsistencias:** detectar No Relevantes que activan reglas de negocio, o Relevantes que no activan reglas.
5. **Consulta de revisión humana:** identificar normativas con explicación débil, insuficiente o poco alineada con las reglas de negocio.

> **Pregunta central:** ¿La clasificación asignada por el agente IA está suficientemente explicada y es válida para el negocio?

**5. Auditoría humana simulada.** Cada grupo deberá auditar al menos cinco normativas, registrando: normativa revisada, clasificación IA, reglas activadas, evidencia textual, juicio del grupo (Validada, Corregida o Requiere más antecedentes) y justificación.

## 5. Entregables e informe

Entregar un script Cypher reproducible con carga del dataset, creación de nodos y relaciones, etiquetas, reglas de negocio, evidencia textual, consultas y auditoría humana simulada. El informe debe seguir la plantilla entregada por el docente:

- 2.1 Construcción del grafo desde el dataset;
- 2.2 Representación de clasificación, explicación y evidencia;
- 2.3 Aplicación de reglas de negocio y etiquetas;
- 2.4 Consultas de explicabilidad;
- 2.5 Auditoría humana simulada.
- Referencias Bibliográficas.

## 6. Referencias bibliográficas

1. Arrieta, A. B., Díaz-Rodríguez, N., Del Ser, J., Bennetot, A., Tabik, S., Barbado, A., García, S., Gil-López, S., Molina, D., Benjamins, R., Chatila, R., & Herrera, F. (2020). Explainable artificial intelligence (XAI): Concepts, taxonomies, opportunities and challenges toward responsible AI. *Information Fusion, 58*, 82–115. https://doi.org/10.1016/j.inffus.2019.12.012
2. Neo4j. (s. f.). *The Neo4j Cypher Manual*. Recuperado el 4 de junio de 2026, de https://neo4j.com/docs/cypher-manual/current/
3. Neo4j. (s. f.). *What is graph data modeling?* Recuperado el 4 de junio de 2026, de https://neo4j.com/docs/getting-started/data-modeling/
4. Ribeiro, M. T., Singh, S., & Guestrin, C. (2016). "Why should I trust you?": Explaining the predictions of any classifier. En *Proceedings of the 22nd ACM SIGKDD International Conference on Knowledge Discovery and Data Mining* (pp. 1135–1144). Association for Computing Machinery. https://doi.org/10.1145/2939672.2939778
5. Robinson, I., Webber, J., & Eifrem, E. (2015). *Graph databases: New opportunities for connected data* (2.ª ed.). O'Reilly Media.
