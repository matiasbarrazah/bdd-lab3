// =====================================================================
// TAREA DE LABORATORIO 3 - NEO4J
// Grafo de Explicabilidad para Auditoría de Clasificación Normativa
// INF-325 Bases de Datos Avanzadas
// ---------------------------------------------------------------------
// Script Cypher reproducible: carga del dataset, creación de nodos y
// relaciones, etiquetas, reglas de negocio, evidencia textual,
// auditoría humana simulada y consultas de explicabilidad.
//
// REQUISITO PREVIO:
//   Copiar el archivo "normativas_clasificadas_IA.csv" a la carpeta
//   "import" de la base de datos Neo4j (Neo4j Desktop:
//   ... > Open folder > Import). Luego ejecutar este script completo
//   en Neo4j Browser o cypher-shell.
//
//   Neo4j 5.x recomendado. El script es idempotente: puede ejecutarse
//   varias veces sin duplicar nodos (usa MERGE y restricciones únicas).
// =====================================================================


// =====================================================================
// 0) LIMPIEZA OPCIONAL (descomentar para reconstruir el grafo desde cero)
// =====================================================================
// MATCH (n) DETACH DELETE n;


// =====================================================================
// 1) RESTRICCIONES E ÍNDICES (integridad y rendimiento)
// =====================================================================
CREATE CONSTRAINT normativa_name IF NOT EXISTS
  FOR (n:Normativa) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT fuente_nombre IF NOT EXISTS
  FOR (f:Fuente) REQUIRE f.nombre IS UNIQUE;
CREATE CONSTRAINT tipodoc_nombre IF NOT EXISTS
  FOR (t:TipoDocumento) REQUIRE t.nombre IS UNIQUE;
CREATE CONSTRAINT agente_nombre IF NOT EXISTS
  FOR (a:AgenteIA) REQUIRE a.nombre IS UNIQUE;
CREATE CONSTRAINT regla_nombre IF NOT EXISTS
  FOR (r:ReglaNegocio) REQUIRE r.nombre IS UNIQUE;
CREATE CONSTRAINT clasif_id IF NOT EXISTS
  FOR (c:ClasificacionIA) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT explic_id IF NOT EXISTS
  FOR (e:ExplicacionIA) REQUIRE e.id IS UNIQUE;
CREATE CONSTRAINT evidencia_id IF NOT EXISTS
  FOR (ev:EvidenciaTextual) REQUIRE ev.id IS UNIQUE;
CREATE CONSTRAINT auditoria_id IF NOT EXISTS
  FOR (au:AuditoriaHumana) REQUIRE au.id IS UNIQUE;


// =====================================================================
// 2) AGENTE IA (nodo único, autor de todas las clasificaciones)
// =====================================================================
MERGE (a:AgenteIA {nombre: 'Agente IA Normativo SII'})
  SET a.tecnica       = 'NLP + RAG',
      a.descripcion   = 'Agente que clasifica normativas del SII como Relevante / No Relevante para el cumplimiento normativo del negocio Fintech.';


// =====================================================================
// 3) CARGA DEL DATASET -> Normativa, Fuente, TipoDocumento,
//    ClasificacionIA, ExplicacionIA  (1 fila CSV = 1 normativa)
// =====================================================================
LOAD CSV WITH HEADERS FROM 'file:///normativas_clasificadas_IA.csv' AS row
WITH row WHERE row.name IS NOT NULL AND trim(row.name) <> ''

// --- Normativa (nodo central) ---
MERGE (n:Normativa {name: trim(row.name)})
  SET n.description     = row.description,
      n.url             = row.url,
      n.tipo_documento  = row.tipo_documento,
      n.cuerpo          = row.cuerpo,
      n.relevancia      = row.relevancia,
      n.explicacion     = row.explicacion,
      n.fuente          = row.fuente,
      n.len_explicacion = size(coalesce(row.explicacion, ''))

// --- Fuente (compartida) ---
MERGE (f:Fuente {nombre: trim(coalesce(row.fuente, 'Fuente desconocida'))})
MERGE (n)-[:EMITIDA_POR]->(f)

// --- Tipo de documento (compartido: Circular / Resolución) ---
MERGE (td:TipoDocumento {nombre: trim(row.tipo_documento)})
MERGE (n)-[:ES_TIPO]->(td)

// --- Clasificación IA (una por normativa) ---
MERGE (c:ClasificacionIA {id: trim(row.name)})
  SET c.valor = row.relevancia
MERGE (n)-[:TIENE_CLASIFICACION]->(c)

// --- Agente que generó la clasificación ---
WITH n, c, row
MATCH (a:AgenteIA {nombre: 'Agente IA Normativo SII'})
MERGE (c)-[:GENERADA_POR]->(a)
MERGE (n)-[:CLASIFICADA_POR]->(a)

// --- Explicación IA (una por normativa, colgando de la clasificación) ---
MERGE (e:ExplicacionIA {id: trim(row.name)})
  SET e.texto   = row.explicacion,
      e.longitud = size(coalesce(row.explicacion, ''))
MERGE (c)-[:TIENE_EXPLICACION]->(e)
MERGE (n)-[:TIENE_EXPLICACION]->(e);


// =====================================================================
// 4) ETIQUETAS POR TIPO DOCUMENTAL Y POR CLASIFICACIÓN  (Requisito 2)
//    :Circular / :Resolucion  y  :Relevante / :NoRelevante
// =====================================================================
MATCH (n:Normativa) WHERE n.tipo_documento = 'Circular'    SET n:Circular;
MATCH (n:Normativa) WHERE n.tipo_documento = 'Resolución'  SET n:Resolucion;
MATCH (n:Normativa) WHERE n.relevancia     = 'Relevante'   SET n:Relevante;
MATCH (n:Normativa) WHERE n.relevancia     = 'No Relevante' SET n:NoRelevante;


// =====================================================================
// 5) REGLAS DE NEGOCIO PREESTABLECIDAS  (Requisito 3)
//    18 reglas:  12 por palabra clave (Tabla 3) + 6 referencias
//    normativas (Tabla 2).
//    'modo':
//       'contains' -> coincidencia por substring (toLower CONTAINS)
//       'regex'    -> coincidencia con límite de palabra (\b) para
//                     evitar falsos positivos de tokens cortos
//                     (p.ej. 'POS' dentro de "disposiciones").
// =====================================================================
WITH [
  // ---- Tabla 3: palabras clave de negocio ----
  {nombre:'boleta',                       categoria:'Palabra clave', modo:'contains', patron:'boleta'},
  {nombre:'comprobante electrónico',      categoria:'Palabra clave', modo:'contains', patron:'comprobante electrónico'},
  {nombre:'registro de compra',           categoria:'Palabra clave', modo:'contains', patron:'registro de compra'},
  {nombre:'registro de venta',            categoria:'Palabra clave', modo:'contains', patron:'registro de venta'},
  {nombre:'cumplimiento tributario',      categoria:'Palabra clave', modo:'contains', patron:'cumplimiento tributario'},
  {nombre:'inicio de actividades',        categoria:'Palabra clave', modo:'contains', patron:'inicio de actividades'},
  {nombre:'medios de pago electrónicos',  categoria:'Palabra clave', modo:'contains', patron:'medios de pago electrónicos'},
  {nombre:'POS',                          categoria:'Palabra clave', modo:'regex',    patron:'(?i).*\\bpos\\b.*'},
  {nombre:'P.O.S',                        categoria:'Palabra clave', modo:'regex',    patron:'(?i).*\\bp\\.o\\.s\\b.*'},
  {nombre:'puntos de venta',              categoria:'Palabra clave', modo:'contains', patron:'puntos de venta'},
  {nombre:'operadores y administradores', categoria:'Palabra clave', modo:'contains', patron:'operadores y administradores'},
  {nombre:'comercio electrónico',         categoria:'Palabra clave', modo:'contains', patron:'comercio electrónico'},
  // ---- Tabla 2: referencias normativas relevantes ----
  {nombre:'Resolución 176 de 2020',           categoria:'Referencia normativa', modo:'contains', patron:'176 de 2020'},
  {nombre:'Resolución 76 de 2021',            categoria:'Referencia normativa', modo:'contains', patron:'76 de 2021'},
  {nombre:'Resolución 79 de 2025',            categoria:'Referencia normativa', modo:'contains', patron:'79 de 2025'},
  {nombre:'Resolución 59 de 2025',            categoria:'Referencia normativa', modo:'contains', patron:'59 de 2025'},
  {nombre:'Circular 38 de 2025',              categoria:'Referencia normativa', modo:'contains', patron:'38 de 2025'},
  {nombre:'Artículo 68 del Código Tributario',categoria:'Referencia normativa', modo:'contains', patron:'artículo 68 del código tributario'}
] AS reglas
UNWIND reglas AS regla
MERGE (rn:ReglaNegocio {nombre: regla.nombre})
  SET rn.categoria = regla.categoria,
      rn.modo      = regla.modo,
      rn.patron    = regla.patron;


// =====================================================================
// 6) ACTIVACIÓN DE REGLAS + EVIDENCIA TEXTUAL  (Requisitos 1 y 3)
//    Una normativa activa una regla si el patrón aparece en
//    nombre + descripción + cuerpo + explicación.
//    Por cada (normativa, regla activada) se crea un nodo
//    :EvidenciaTextual con el fragmento que respalda la decisión.
// =====================================================================
MATCH (n:Normativa)
MATCH (rn:ReglaNegocio)
WITH n, rn,
     toLower(coalesce(n.name,'')        + ' ' +
             coalesce(n.description,'')  + ' ' +
             coalesce(n.cuerpo,'')       + ' ' +
             coalesce(n.explicacion,'')) AS blob
WHERE (rn.modo = 'contains' AND blob CONTAINS toLower(rn.patron))
   OR (rn.modo = 'regex'    AND blob =~ rn.patron)
MERGE (n)-[:ACTIVA_REGLA]->(rn)
MERGE (ev:EvidenciaTextual {id: n.name + ' :: ' + rn.nombre})
  SET ev.regla     = rn.nombre,
      ev.normativa = n.name,
      ev.campo     = CASE
                       WHEN toLower(coalesce(n.name,''))        CONTAINS toLower(rn.patron) THEN 'nombre'
                       WHEN toLower(coalesce(n.description,'')) CONTAINS toLower(rn.patron) THEN 'descripcion'
                       WHEN toLower(coalesce(n.explicacion,'')) CONTAINS toLower(rn.patron) THEN 'explicacion'
                       ELSE 'cuerpo'
                     END,
      ev.fragmento = substring(coalesce(n.description, n.cuerpo, ''), 0, 280),
      ev.contexto  = substring(coalesce(n.cuerpo,''), 0, 280)
MERGE (n)-[:RESPALDADA_POR]->(ev)
MERGE (ev)-[:EVIDENCIA_DE]->(rn);


// =====================================================================
// 7) ETIQUETAS DE EXPLICABILIDAD  (Requisito 2 y objetivos 5-6)
//    :ExplicacionValida / :ExplicacionDebil / :RequiereRevision
//
//    Criterios adoptados:
//      - ExplicacionDebil   : explicación corta (< 200 caracteres),
//                             típicamente genérica ("No cumple reglas
//                             de negocio."), poco trazable.
//      - ExplicacionValida  : explicación suficientemente desarrollada.
//      - RequiereRevision   : explicación débil  Ó  inconsistencia entre
//                             la clasificación IA y las reglas de negocio
//                             (No Relevante que activa reglas, o
//                              Relevante que no activa ninguna regla).
// =====================================================================

// 7.1 Explicación débil / válida según longitud
MATCH (n:Normativa)
WHERE n.len_explicacion < 200
SET n:ExplicacionDebil;

MATCH (n:Normativa)
WHERE n.len_explicacion >= 200
SET n:ExplicacionValida;

// 7.2 Requiere revisión por explicación débil
MATCH (n:ExplicacionDebil)
SET n:RequiereRevision;

// 7.3 Requiere revisión: No Relevante que SÍ activa reglas de negocio
MATCH (n:NoRelevante)
WHERE (n)-[:ACTIVA_REGLA]->()
SET n:RequiereRevision;

// 7.4 Requiere revisión: Relevante que NO activa ninguna regla de negocio
MATCH (n:Relevante)
WHERE NOT (n)-[:ACTIVA_REGLA]->()
SET n:RequiereRevision;


// =====================================================================
// 8) AUDITORÍA HUMANA SIMULADA  (Requisito 5: al menos 5 normativas)
//    juicio ∈ {Validada, Corregida, Requiere más antecedentes}
// =====================================================================
WITH [
  { normativa:'Circular N° 12 del 30 de Enero del 2025',
    auditor:'Equipo de Cumplimiento',
    juicio:'Validada',
    justificacion:'Clasificada Relevante por la IA. Activa reglas de negocio (boleta, cumplimiento tributario) con evidencia textual coherente. La explicación es suficiente y trazable; la decisión se acepta sin cambios.' },

  { normativa:'Resolución Exenta SII N° 81 del 30 de Junio del 2025',
    auditor:'Equipo de Cumplimiento',
    juicio:'Corregida',
    justificacion:'Clasificada No Relevante por la IA, pero activa 9 reglas de negocio (boleta, POS, medios de pago electrónicos, comercio electrónico, etc.) con abundante evidencia textual. Existe inconsistencia clasificación-reglas: a juicio humano debería ser Relevante.' },

  { normativa:'Resolución Exenta SII N° 59 del 06 de Mayo del 2025',
    auditor:'Equipo de Cumplimiento',
    juicio:'Corregida',
    justificacion:'Marcada No Relevante pese a activar múltiples reglas de negocio asociadas a boletas y medios de pago electrónicos. La evidencia textual contradice la clasificación; se corrige a Relevante para revisión de cumplimiento.' },

  { normativa:'Circular N° 13 del 07 de Febrero del 2025',
    auditor:'Equipo de Cumplimiento',
    juicio:'Requiere más antecedentes',
    justificacion:'Explicación débil y genérica ("No cumple reglas de negocio.", 28 caracteres). No entrega evidencia suficiente para auditar la decisión; se solicita ampliar la explicación del agente IA.' },

  { normativa:'Resolución Exenta SII N° 05 del 09 de Enero del 2025',
    auditor:'Equipo de Cumplimiento',
    juicio:'Requiere más antecedentes',
    justificacion:'Explicación insuficiente (< 200 caracteres) y baja explicabilidad. No es posible confirmar ni refutar la clasificación con la evidencia disponible; requiere revisión humana adicional.' },

  { normativa:'Resolución Exenta SII N° 79 del 26 de Junio del 2025',
    auditor:'Equipo de Cumplimiento',
    juicio:'Validada',
    justificacion:'Clasificada Relevante. Activa 4 reglas de negocio con evidencia textual sólida y explicación bien desarrollada. La decisión de la IA es trazable y se valida.' }
] AS auditorias
UNWIND auditorias AS a
MATCH (n:Normativa {name: a.normativa})
MERGE (au:AuditoriaHumana {id: a.normativa})
  SET au.auditor       = a.auditor,
      au.juicio        = a.juicio,
      au.justificacion = a.justificacion,
      au.fecha         = date()
MERGE (n)-[:AUDITADA_POR]->(au)
SET n:Auditada;


// =====================================================================
// =====================================================================
//                      CONSULTAS DE EXPLICABILIDAD
//          (Requisito 4 - ejecutar individualmente y capturar)
// =====================================================================
// =====================================================================


// ---------------------------------------------------------------------
// VISTA GENERAL DEL GRAFO (para captura de panorama)
// ---------------------------------------------------------------------
// MATCH p=(n:Normativa)-[r]-(x)
// RETURN p LIMIT 200;


// ---------------------------------------------------------------------
// CONSULTA 1 - Clasificación general
// Normativas Relevantes y No Relevantes con nombre, tipo documental,
// fuente, descripción y explicación IA.
// ---------------------------------------------------------------------
MATCH (n:Normativa)-[:EMITIDA_POR]->(f:Fuente)
MATCH (n)-[:ES_TIPO]->(td:TipoDocumento)
MATCH (n)-[:TIENE_CLASIFICACION]->(c:ClasificacionIA)-[:TIENE_EXPLICACION]->(e:ExplicacionIA)
RETURN c.valor              AS clasificacion_IA,
       td.nombre            AS tipo_documento,
       n.name               AS normativa,
       f.nombre             AS fuente,
       n.description        AS descripcion,
       e.texto              AS explicacion_IA
ORDER BY clasificacion_IA DESC, tipo_documento, normativa;


// ---------------------------------------------------------------------
// CONSULTA 2 - Explicación de una normativa específica
// Clasificación IA, explicación, reglas activadas y evidencia textual.
// (cambiar el nombre del parámetro para auditar otra normativa)
// ---------------------------------------------------------------------
MATCH (n:Normativa {name: 'Circular N° 12 del 30 de Enero del 2025'})
MATCH (n)-[:TIENE_CLASIFICACION]->(c:ClasificacionIA)-[:TIENE_EXPLICACION]->(e:ExplicacionIA)
OPTIONAL MATCH (n)-[:ACTIVA_REGLA]->(rn:ReglaNegocio)
OPTIONAL MATCH (n)-[:RESPALDADA_POR]->(ev:EvidenciaTextual)-[:EVIDENCIA_DE]->(rn)
RETURN n.name                          AS normativa,
       c.valor                         AS clasificacion_IA,
       e.texto                         AS explicacion_IA,
       collect(DISTINCT rn.nombre)     AS reglas_activadas,
       collect(DISTINCT ev.fragmento)  AS evidencia_textual;

// Variante visual (grafo de la ruta explicable de una normativa):
// MATCH path = (n:Normativa {name:'Circular N° 12 del 30 de Enero del 2025'})
//   -[:TIENE_CLASIFICACION|TIENE_EXPLICACION|ACTIVA_REGLA|RESPALDADA_POR|EVIDENCIA_DE|EMITIDA_POR|ES_TIPO|CLASIFICADA_POR|AUDITADA_POR]->(x)
// RETURN path;


// ---------------------------------------------------------------------
// CONSULTA 3 - Normativas Relevantes con respaldo de negocio
// Relevantes que activan reglas de negocio y cuentan con evidencia.
// ---------------------------------------------------------------------
MATCH (n:Relevante)-[:ACTIVA_REGLA]->(rn:ReglaNegocio)
MATCH (n)-[:RESPALDADA_POR]->(ev:EvidenciaTextual)-[:EVIDENCIA_DE]->(rn)
RETURN n.name                         AS normativa,
       n.tipo_documento               AS tipo,
       count(DISTINCT rn)             AS n_reglas,
       collect(DISTINCT rn.nombre)    AS reglas_activadas,
       count(DISTINCT ev)             AS n_evidencias
ORDER BY n_reglas DESC, normativa;


// ---------------------------------------------------------------------
// CONSULTA 4 - Posibles inconsistencias
// (a) No Relevantes que SÍ activan reglas de negocio, o
// (b) Relevantes que NO activan ninguna regla.
// ---------------------------------------------------------------------
// (a) No Relevante con reglas activadas
MATCH (n:NoRelevante)-[:ACTIVA_REGLA]->(rn:ReglaNegocio)
RETURN 'No Relevante activa reglas' AS tipo_inconsistencia,
       n.name                       AS normativa,
       count(DISTINCT rn)           AS n_reglas,
       collect(DISTINCT rn.nombre)  AS reglas_activadas
ORDER BY n_reglas DESC

UNION

// (b) Relevante sin reglas activadas
MATCH (n:Relevante)
WHERE NOT (n)-[:ACTIVA_REGLA]->()
RETURN 'Relevante sin reglas'       AS tipo_inconsistencia,
       n.name                       AS normativa,
       0                            AS n_reglas,
       []                           AS reglas_activadas;


// ---------------------------------------------------------------------
// CONSULTA 5 - Revisión humana
// Normativas con explicación débil, insuficiente o poco alineada con
// las reglas de negocio (etiqueta :RequiereRevision).
// ---------------------------------------------------------------------
MATCH (n:RequiereRevision)
MATCH (n)-[:TIENE_CLASIFICACION]->(c:ClasificacionIA)-[:TIENE_EXPLICACION]->(e:ExplicacionIA)
OPTIONAL MATCH (n)-[:ACTIVA_REGLA]->(rn:ReglaNegocio)
RETURN n.name                                       AS normativa,
       c.valor                                      AS clasificacion_IA,
       e.longitud                                   AS largo_explicacion,
       'ExplicacionDebil' IN labels(n)              AS explicacion_debil,
       count(DISTINCT rn)                           AS n_reglas_activadas,
       CASE
         WHEN c.valor = 'No Relevante' AND count(DISTINCT rn) > 0 THEN 'Inconsistencia: No Relevante activa reglas'
         WHEN c.valor = 'Relevante'    AND count(DISTINCT rn) = 0 THEN 'Inconsistencia: Relevante sin reglas'
         WHEN n.len_explicacion < 200                              THEN 'Explicación insuficiente'
         ELSE 'Otra'
       END                                          AS motivo_revision
ORDER BY n_reglas_activadas DESC, largo_explicacion ASC;


// ---------------------------------------------------------------------
// CONSULTA 6 (extra) - Resultado de la auditoría humana simulada
// ---------------------------------------------------------------------
MATCH (n:Auditada)-[:AUDITADA_POR]->(au:AuditoriaHumana)
MATCH (n)-[:TIENE_CLASIFICACION]->(c:ClasificacionIA)
OPTIONAL MATCH (n)-[:ACTIVA_REGLA]->(rn:ReglaNegocio)
RETURN n.name                       AS normativa_revisada,
       c.valor                      AS clasificacion_IA,
       collect(DISTINCT rn.nombre)  AS reglas_activadas,
       au.juicio                    AS juicio_grupo,
       au.justificacion             AS justificacion
ORDER BY juicio_grupo, normativa_revisada;


// ---------------------------------------------------------------------
// CONSULTA 7 (extra) - Resumen estadístico del grafo
// ---------------------------------------------------------------------
MATCH (n:Normativa)
RETURN count(n)                                                          AS total_normativas,
       count(CASE WHEN n:Relevante        THEN 1 END)                    AS relevantes,
       count(CASE WHEN n:NoRelevante      THEN 1 END)                    AS no_relevantes,
       count(CASE WHEN n:Circular         THEN 1 END)                    AS circulares,
       count(CASE WHEN n:Resolucion       THEN 1 END)                    AS resoluciones,
       count(CASE WHEN n:ExplicacionDebil THEN 1 END)                    AS explicacion_debil,
       count(CASE WHEN n:RequiereRevision THEN 1 END)                    AS requieren_revision,
       count(CASE WHEN n:Auditada         THEN 1 END)                    AS auditadas;
