# Auralix Hub - Plan Maestro UI/UX (Prompt Completo)

Fecha: 2026-04-01
Alcance: Frontend Flutter Web + Multiplataforma
Objetivo: Cumplir al 100% el prompt de UI/UX terminal-first, dinámico y desacoplado del backend.

## 1) Visión de Producto
Auralix Hub debe sentirse como una consola moderna para desarrolladores: visual consistente tipo terminal, navegación clara, datos dinámicos por metadatos, y experiencia fluida para explorar APIs, leer docs, ejecutar sandbox y gestionar recursos.

## 2) Principios de Diseño (No Negociables)
- Sin negro puro en fondos: usar dark estilizado (azul/verde/neón).
- Tipografía monoespaciada legible para datos técnicos.
- Coherencia terminal en mensajes, logs, outputs, errores y estados del sistema.
- Todo contenido de APIs debe ser dinámico (sin hardcode de servicios/categorías).
- UI desacoplada del backend: adaptación automática a nuevos servicios.

## 3) Trazabilidad de Requerimientos del Prompt

### 3.1 Estado general (Abril 2026)
- Completado parcial:
  - Base de temas terminal y presets Cyber Green / Ocean Blue / Neo Violet.
  - Landing rediseñada con secciones principales.
  - Docs dinámica basada en catálogo de servicios.
  - Sandbox con prefill dinámico por servicio.
  - Capa base de catálogo dinámico (provider/model normalizador).
- Pendiente clave:
  - Endpoint central backend formalizado con contrato estable (/services).
  - Coherencia visual profunda en todas rutas (login/register/dashboard/billing/settings).
  - Dashboard dinámico por catálogo (hoy sigue orientado a métricas + logs, falta capa de descubrimiento de servicios).
  - QA funcional, pruebas UI y hardening de edge cases.

### 3.2 Matriz de cumplimiento
- Landing pública completa en /: Parcial (estructura creada, falta refinamiento final y validación de contenido real dinámico).
- Sistema de diseño modular con tokens (color/tipo/espaciado/bordes/efectos): Parcial alto (base lista, falta documentación y adopción total en todos componentes).
- Temas preconfigurados + persistencia: Cumplido (validar UX de selector y fallback legacy).
- Componentes terminal (inputs/tarjetas logs/badges/botones/consola): Parcial alto (existen, falta unificar estilos en billing/auth/legal).
- Animaciones (cursor/typewriter/transiciones/microinteracciones/progressive render): Parcial (implementado en áreas clave, falta estandarizar por ruta).
- Rutas principales consistentes: Parcial (routing completo, coherencia visual pendiente por pantalla).
- Consumo dinámico desde endpoint central: Parcial (frontend preparado con adapter flexible, backend central pendiente de contrato fijo).
- Docs /docs auto-render por metadata: Parcial alto (ya dinámica, falta ampliar soporte de ejemplos y estados avanzados).
- Sandbox /sandbox dinámico por parámetros: Parcial alto (base lista, faltan controles avanzados por tipo de parámetro).
- Snippets multilenguaje + URL + password: Parcial alto (flujo existe, falta UX polishing terminal y métricas).
- Estados HTTP visuales (200,201,301,304,400,401,403,404,429,500,502,503): Cumplido base (falta cobertura visual homogénea en toda app).
- UX fluida orientada a developer: Parcial (funciona, falta pass de usabilidad integral y performance).

## 4) Arquitectura Objetivo (Frontend)

### 4.1 Capa de datos dinámica
- Service Catalog central:
  - `ServiceCatalogRepository`
  - `ApiServiceMetadata`
  - Provider global Riverpod
- Soporte de contrato flexible + fallback:
  - Priorizar `/services` o `/api/hub/services` (configurable por env)
  - Normalización de keys para compatibilidad temporal

### 4.2 Capa de diseño
- `ThemeData` extendido con `ThemeExtension` (tokens + métricas)
- Librería de componentes terminal reutilizables:
  - inputs CLI
  - cards glow
  - badges HTTP
  - tablas/log panels
  - consola interactiva

### 4.3 Capa de experiencia
- Navegación por intención (descubrir -> probar -> integrar -> monitorear)
- Contexto persistente entre Docs y Sandbox (serviceId, endpoint, method, body seed)
- Mensajería técnica clara (status, errores, límites, tiempos)

## 5) Plan de Ejecución por Fases (Recomendado)

## Fase 0 - Contrato Backend/Frontend (Bloqueante)
Objetivo: cerrar contrato estable de metadatos.

Entregables:
- Especificación oficial de `GET /services` (versionada).
- Campos mínimos requeridos:
  - id, name, description, project, categories[], tags[], method, endpoint
  - parameters[] (name, type, required, location, description, example)
  - examples{curl,nodejs,python,...}
  - responses/statusCodes
  - sandbox config
  - related[]
- Ejemplo JSON real de producción.

Aceptación:
- Frontend puede renderizar landing/docs/sandbox/dashboard sin hardcode.

## Fase 1 - Hardening del Catálogo Dinámico
Objetivo: robustecer capa de datos actual.

Tareas:
- Añadir caché + TTL del catálogo.
- Manejar reintentos y errores de red con estados UX específicos.
- Validación de esquema (campos faltantes, tipos inválidos).
- Telemetría de parseo fallido por servicio.

Aceptación:
- 0 crashes ante payloads parciales.
- fallback visual limpio cuando falta metadata.

## Fase 2 - Design System 1.0 (Documentado)
Objetivo: consolidar identidad terminal en todo frontend.

Tareas:
- Definir tokens oficiales (color, type scale, spacing, radius, glow, motion).
- Crear guía visual interna en docs.
- Normalizar componentes existentes bajo tokens.
- Añadir estados de componente: default/hover/focus/error/disabled/loading.

Aceptación:
- Ninguna pantalla usa estilos sueltos fuera del sistema.

## Fase 3 - Landing / Pública (/) Final
Objetivo: cerrar la landing como punto de entrada comercial+técnico.

Tareas:
- Revisar copy técnico por bloque.
- Hero consola con flujo real de service metadata.
- Secciones: features, demo request/response, docs preview, sandbox preview, snippets, planes, seguridad, footer legal.
- SEO base web (title/meta/social).

Aceptación:
- Landing usable sin auth y 100% responsive.
- CTA claros hacia login/register/docs.

## Fase 4 - Docs Dinámica 2.0 (/docs)
Objetivo: documentación generada por metadata sin hardcode.

Tareas:
- Soporte completo de ejemplos multilenguaje (Node.js explícito + Python + cURL + JS).
- Render de parámetros por ubicación (path/query/header/body).
- Tabla de status codes con mensajes por servicio.
- Sugerencias dinámicas por `related[]` y por categorías compartidas.

Aceptación:
- Crear nuevo servicio en backend y verlo en docs sin tocar frontend.

## Fase 5 - Sandbox Dinámico 2.0 (/sandbox)
Objetivo: ejecución real de requests desde metadata.

Tareas:
- Generación de form dinámica por tipos (string/number/bool/array/object/enum).
- Presets por servicio y método.
- Historial local de ejecuciones por usuario/sesión.
- Vista terminal de response con headers, tiempo y créditos restantes.

Aceptación:
- 100% de servicios del catálogo ejecutables desde sandbox sin UI manual.

## Fase 6 - Dashboard Núcleo (/dashboard)
Objetivo: dashboard como centro de interacción principal.

Tareas:
- Añadir widgets dinámicos de descubrimiento:
  - servicios destacados
  - categorías más usadas
  - sugerencias relacionadas
- Integrar logs + métricas + accesos rápidos a docs/sandbox por servicio.
- Mejorar tablas tipo logs y estados HTTP.

Aceptación:
- Dashboard guía el flujo completo discover -> test -> integrate.

## Fase 7 - Snippets Pro (/snippets)
Objetivo: consolidar feature de snippets para dev workflow.

Tareas:
- Mejorar UX de creación/edición y preview syntax highlight.
- URL permanente + protección por contraseña + UX de error clara.
- Etiquetado y búsqueda por lenguaje.

Aceptación:
- Compartir snippet protegido y abrirlo externamente sin fricción.

## Fase 8 - Consistencia de Rutas Secundarias
Objetivo: homogeneidad total en /login /register /billing /settings /legal.

Tareas:
- Aplicar tokens y componentes terminal a formularios, tarjetas y estados.
- Uniformar microinteracciones y feedback visual.
- Revisar accesibilidad (contraste y focus visible).

Aceptación:
- Misma identidad visual y comportamiento en todas rutas.

## Fase 9 - QA, Performance y Cierre
Objetivo: release estable.

Tareas:
- Test manual E2E por ruta principal.
- Checkpoints performance web (first paint, smooth scroll, animation jank).
- Revisar analyzer/lints y corregir warnings pendientes.
- Pruebas de fallback sin catálogo y con catálogo incompleto.

Aceptación:
- Build limpia + checklist DoD completo.

## 6) Backlog por Ruta (Checklist Operativo)

### / (landing)
- [ ] Hero terminal con data dinámica real
- [ ] Sección docs con ejemplos reales del catálogo
- [ ] Sección sandbox con servicio destacado real
- [ ] Sección snippets, planes, seguridad, footer legal completo
- [ ] Responsive audit (mobile/tablet/desktop)

### /login y /register
- [ ] Inputs CLI + validación UX consistente
- [ ] Mensajería de error/success terminal-style
- [ ] Microinteracciones de carga y submit

### /dashboard
- [ ] Widget de servicios dinámicos
- [ ] Sugerencias por relación entre servicios
- [ ] Logs y status codes homogéneos

### /docs
- [ ] Soporte Node.js explícito en snippets
- [ ] Render de parámetros por location
- [ ] Status table por servicio

### /sandbox
- [ ] Form generator tipado por metadata
- [ ] Presets por servicio
- [ ] Historial y re-ejecución rápida

### /snippets
- [ ] Búsqueda/filtro por lenguaje y tags
- [ ] UX password lock más clara
- [ ] Copy/share robusto

### /billing
- [ ] Integración robusta de planes dinámicos
- [ ] Estados de pago/errores en consola
- [ ] Fallback seguro cuando data no llega

### /settings
- [ ] Mejorar selector de tema con preview real
- [ ] Persistencia + restauración de preferencias UX

## 7) Definición de Hecho (DoD)
Una funcionalidad se considera terminada cuando:
- Cumple el prompt funcional y visual.
- Usa metadatos dinámicos (sin hardcode de servicios).
- Tiene estados loading/empty/error/success.
- Es responsive y mantiene consistencia terminal.
- No rompe analyzer ni rutas relacionadas.

## 8) Riesgos y Mitigaciones
- Riesgo: backend sin endpoint central estable.
  - Mitigación: contrato versionado + adapter temporal + feature flag.
- Riesgo: metadata incompleta por servicio.
  - Mitigación: validación de esquema + fallback UX controlado.
- Riesgo: inconsistencia visual por estilos sueltos.
  - Mitigación: bloquear nuevos estilos fuera de design tokens.

## 9) Orden de Prioridad (Sprints)
- Sprint 1: Fase 0 + Fase 1
- Sprint 2: Fase 2 + Fase 3
- Sprint 3: Fase 4 + Fase 5
- Sprint 4: Fase 6 + Fase 7
- Sprint 5: Fase 8 + Fase 9

## 10) Próximo Paso Inmediato
- Cerrar contrato final de `/services` con backend (Fase 0).
- Luego ejecutar Fase 1 y Fase 2 en paralelo para acelerar.
