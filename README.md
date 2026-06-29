# Laboratorio 3 — Neo4j · Grafo de Explicabilidad para Auditoría de Clasificación Normativa

INF-325 Bases de Datos Avanzadas · UTFSM

## Contenido de la entrega

| Archivo | Descripción |
|---|---|
| `lab3_neo4j.cypher` | Script Cypher **reproducible**: carga del dataset, nodos, relaciones, etiquetas, reglas de negocio, evidencia textual, auditoría humana y las 5 consultas de explicabilidad. |
| `Informe_Lab3_Neo4J.docx` | Informe editable (plantilla del docente). |
| `Informe_Lab3_Neo4J.pdf` | Informe en PDF (formato de entrega). |
| `normativas_clasificadas_IA.csv` | Dataset original (129 normativas). |

## Cómo ejecutar el grafo

1. **Instalar Neo4j** (recomendado Neo4j Desktop, versión 5.x) y crear/abrir una base de datos.
2. **Copiar el CSV a la carpeta `import`** de la base:
   - En Neo4j Desktop: botón `...` de la base → *Open folder* → *Import*, y pegar ahí `normativas_clasificadas_IA.csv`.
3. **Ejecutar el script**: abrir Neo4j Browser y pegar el contenido de `lab3_neo4j.cypher`.
   - Se puede ejecutar todo de una vez (el bloque de carga y modelado).
   - Las **consultas de explicabilidad** (Consultas 1 a 7) conviene ejecutarlas **una por una** para capturar cada resultado.

> El script es **idempotente** (usa restricciones `UNIQUE` + `MERGE`): puede re-ejecutarse sin duplicar nodos. Para reconstruir desde cero, descomentar la línea `MATCH (n) DETACH DELETE n;` al inicio.

### Nota sobre el archivo CSV (BOM)
El CSV original viene con marca BOM (UTF-8). Neo4j 5.x la maneja correctamente. Si al cargar `row.name` aparece como `null`, abrir el CSV y volver a guardarlo como **UTF-8 sin BOM**, y volver a ejecutar la carga.

## Modelo del grafo (resumen)

- **Nodo central:** `:Normativa` (etiquetas dinámicas `:Circular`/`:Resolucion`, `:Relevante`/`:NoRelevante`, `:ExplicacionValida`/`:ExplicacionDebil`, `:RequiereRevision`, `:Auditada`).
- **Otros nodos:** `:ClasificacionIA`, `:ExplicacionIA`, `:AgenteIA`, `:Fuente`, `:TipoDocumento`, `:ReglaNegocio`, `:EvidenciaTextual`, `:AuditoriaHumana`.
- **Ruta explicable:** `Normativa → Clasificación IA → Explicación IA → Regla de negocio → Evidencia textual → Auditoría humana`.

## Hallazgos principales (datos reales del dataset)

- 129 normativas: **20 Relevantes**, 109 No Relevantes · 83 Resoluciones, 46 Circulares.
- **90** normativas activan ≥ 1 regla de negocio.
- **70 No Relevantes activan reglas de negocio** → inconsistencia clasificación–reglas (principal hallazgo de auditoría).
- **0 Relevantes** quedan sin regla activada.
- **5** normativas con explicación débil (< 200 caracteres).

## Pendiente del estudiante

El informe incluye recuadros marcados **«[ ESPACIO PARA CAPTURA DE NEO4J BROWSER ]»**. Tras ejecutar el script, reemplazar cada recuadro por la captura real (vista general del grafo, clasificación, ruta explicable, inconsistencias y revisión humana) y completar nombres/correos de los integrantes.
