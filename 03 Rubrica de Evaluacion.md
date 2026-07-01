# Rúbrica de Evaluación

**Laboratorio 3 — INF325 Bases de Datos Avanzadas**

## Escala – Rúbrica

| Sigla | Leyenda | % Logro |
| --- | --- | --- |
| EL (a) | Excelente Logro | 100% |
| CL (b) | Completamente Logrado | 80% |
| L (c) | Logrado | 55% |
| PL (d) | Parcialmente Logrado | 30% |
| NL (e) | No Logrado | 0% |

Puntajes asociados: **EL = 10 · CL = 8 · L = 5,5 · PL = 3 · NL = 0**

## Aspectos a evaluar

### 1. Resumen congruente con el trabajo objeto del informe

| Nivel | Descripción |
| --- | --- |
| EL (10) | Resume con claridad el propósito del laboratorio, dataset, enfoque de grafo, consultas de explicabilidad, resultados principales y aprendizajes; es coherente con todo el informe y no supera la extensión solicitada. |
| CL (8) | Resume correctamente el propósito, dataset, enfoque y resultados, con leves omisiones de detalle o síntesis; mantiene coherencia general con el informe. |
| L (5,5) | Presenta un resumen comprensible, pero incompleto; menciona solo parte del problema, metodología o resultados y su relación con el informe es general. |
| PL (3) | El resumen es superficial, confuso o demasiado descriptivo; no deja claro el objetivo de explicabilidad ni los resultados logrados. |
| NL (0) | No presenta resumen o el texto no se relaciona con el laboratorio. |

### 2. Introducción congruente con el trabajo objeto del informe

| Nivel | Descripción |
| --- | --- |
| EL (10) | Contextualiza correctamente el problema de cumplimiento normativo, la clasificación por IA, la necesidad de auditoría humana y el uso de Neo4j como grafo explicable. |
| CL (8) | Presenta el contexto del problema y menciona IA, normativas y Neo4j, aunque con menor profundidad o conexión entre los elementos. |
| L (5,5) | Introduce el tema de forma básica; explica parcialmente el caso, pero no desarrolla suficientemente la necesidad de explicabilidad o auditoría. |
| PL (3) | La introducción es genérica, poco conectada con el dataset o con el problema de negocio; presenta ideas aisladas. |
| NL (0) | No presenta introducción o esta no guarda relación con el laboratorio. |

### 3. Propone un esquema de base de datos Neo4j según el Requisito N.º 1

| Nivel | Descripción |
| --- | --- |
| EL (10) | Propone un esquema de grafo completo y coherente, con nodos para normativa, clasificación IA, explicación, agente, fuente, tipo documental, reglas de negocio, evidencia y auditoría humana; justifica relaciones y etiquetas. |
| CL (8) | Propone un esquema adecuado con la mayoría de nodos, relaciones y etiquetas requeridas; presenta pequeñas omisiones o justificación limitada. |
| L (5,5) | Propone un esquema funcional, pero incompleto; considera algunos nodos y relaciones esenciales, aunque con poca claridad en reglas, evidencias o etiquetas. |
| PL (3) | El esquema es parcial o confuso; modela principalmente datos tabulares y no representa adecuadamente la explicabilidad de la clasificación IA. |
| NL (0) | No propone esquema de grafo o el esquema no corresponde a Neo4j ni al caso solicitado. |

### 4. Construye la base de datos conforme al Requisito N.º 2

| Nivel | Descripción |
| --- | --- |
| EL (10) | Construye correctamente la base en Neo4j con nodos, relaciones, propiedades y etiquetas consistentes; permite recorrer la ruta explicable entre normativa, clasificación, explicación, regla, evidencia y auditoría. |
| CL (8) | Construye la base correctamente en lo esencial; existen leves omisiones o inconsistencias menores que no impiden consultar el grafo. |
| L (5,5) | Construye una base básica y consultable, pero con relaciones incompletas, etiquetas limitadas o estructura poco orientada a explicabilidad. |
| PL (3) | La base presenta errores importantes de construcción, duplicidad, relaciones mal definidas o ausencia de varios elementos solicitados. |
| NL (0) | No construye la base de datos en Neo4j o no hay evidencia funcional. |

### 5. Procesa e importa los datos en Neo4j conforme al Requisito N.º 3

| Nivel | Descripción |
| --- | --- |
| EL (10) | Importa correctamente el dataset entregado, conserva campos relevantes, limpia o normaliza datos cuando corresponde y evidencia que las normativas, clasificaciones, explicaciones, fuentes y tipos documentales fueron cargados. |
| CL (8) | Importa el dataset y conserva la mayoría de campos relevantes; presenta errores menores de limpieza, nombres o normalización que no afectan el análisis principal. |
| L (5,5) | Importa parcialmente los datos; faltan algunos campos importantes o existen problemas moderados que limitan algunas consultas. |
| PL (3) | La importación presenta errores significativos que impiden representar adecuadamente clasificación, explicación o evidencia. |
| NL (0) | No importa el dataset o no hay evidencia de carga de datos en Neo4j. |

### 6. Diseña, construye y evidencia 5 consultas Cypher según el Requisito N.º 4

| Nivel | Descripción |
| --- | --- |
| EL (10) | Desarrolla las cinco consultas obligatorias de explicabilidad, correctas y con evidencia; responden a clasificación general, explicación específica, respaldo de negocio, inconsistencias y revisión humana. |
| CL (8) | Desarrolla las cinco consultas con resultados mayormente correctos; alguna consulta podría mejorar en precisión, evidencia o interpretación. |
| L (5,5) | Presenta consultas funcionales, pero alguna de las cinco está incompleta, poco alineada al objetivo o con interpretación limitada. |
| PL (3) | Presenta menos de cinco consultas válidas o varias no responden a explicabilidad/auditoría; la evidencia es insuficiente. |
| NL (0) | No presenta consultas Cypher funcionales o no evidencia resultados. |

### 7. Desarrolla conclusiones coherentes e identifica aspectos relevantes

| Nivel | Descripción |
| --- | --- |
| EL (10) | Concluye de forma fundada sobre la utilidad del grafo, el valor de Neo4j, la validez de las explicaciones, los casos que [requieren](?) revisión humana y las limitaciones del enfoque aplicado. |
| CL (8) | Presenta conclusiones coherentes y relacionadas con el trabajo, aunque con menor profundidad en limitaciones o auditoría humana. |
| L (5,5) | Incluye conclusiones generales, parcialmente conectadas con los resultados obtenidos; identifica aspectos relevantes. |
| PL (3) | Las conclusiones son superficiales, repetitivas o poco fundamentadas; no se conectan claramente con las consultas y evidencias. |
| NL (0) | No presenta conclusiones o estas no se relacionan con el trabajo realizado. |

### 8. Presentación y trabajo organizado y claro

| Nivel | Descripción |
| --- | --- |
| EL (10) | Expone de manera ordenada, clara y técnica; explica problema, modelo de grafo, reglas, ejemplos, consultas, hallazgos y auditoría con apoyo visual pertinente. |
| CL (8) | Expone de forma clara y organizada la mayoría de componentes; presenta leves problemas de secuencia, profundidad o apoyo visual. |
| L (5,5) | La exposición permite comprender el trabajo en términos generales, pero con organización regular o ejecución técnica limitada. |
| PL (3) | La exposición es desordenada, poco clara o incompleta; dificulta comprender el grafo, las consultas o la auditoría realizada. |
| NL (0) | No expone o la presentación no corresponde al laboratorio. |

### 9. Exposición dentro del tiempo establecido

| Nivel | Descripción |
| --- | --- |
| EL (10) | Respeta completamente el tiempo restringido y distribuye adecuadamente la exposición entre contexto, desarrollo, consultas, auditoría y conclusiones. |
| CL (8) | Respeta el tiempo con una desviación menor; la distribución de contenido es adecuada, aunque perfectible. |
| L (5,5) | Presenta una desviación moderada de tiempo o dedica demasiado espacio a algunos contenidos en desmedro de otros. |
| PL (3) | Se aleja significativamente del tiempo restringido y deja contenidos sin explicar o los aborda apresuradamente. |
| NL (0) | No realiza exposición o incumple totalmente el tiempo establecido. |

### 10. Responde las preguntas planteadas en la exposición

| Nivel | Descripción |
| --- | --- |
| EL (10) | Responde con dominio técnico y evidencia del trabajo realizado; justifica decisiones de modelamiento, reglas, etiquetas, consultas y auditoría humana. |
| CL (8) | Responde adecuadamente la mayoría de preguntas con leves imprecisiones o menor profundidad en aspectos técnicos. |
| L (5,5) | Responde preguntas básicas, pero evidencia dudas en decisiones de grafo, reglas de negocio o consultas de explicabilidad. |
| PL (3) | Responde con dificultad, de forma incompleta o poco fundamentada; muestra bajo dominio de la solución desarrollada. |
| NL (0) | No responde preguntas o las respuestas no se relacionan con el trabajo. |

## Puntajes y porcentajes

| Ítem o Pauta de Corrección | Puntaje máximo | % Ponderación | Puntaje Obtenido |
| --- | --- | --- | --- |
| Rúbrica | 100 puntos | 100% | |
