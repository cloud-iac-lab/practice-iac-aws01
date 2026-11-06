# ADR-0001 — Arquitectura del stack web y agrupación de módulos

- **Estado**: Aceptada
- **Fecha**: 2026-11-04
- **Autores**: architect

## Contexto
El proyecto anterior (proyecto1) se creó por "vibecoding": módulos regados y
carpetas de scaffold vacías. Para proyecto2 se busca una estructura por dominio
y un flujo SDD con gates de calidad.

## Decisión
1. **Agrupar módulos por dominio** en `infraestructure/modules/`:
   - `networking/` → `vpc`, `route53`, `alb`
   - `compute/` → `ec2`
   - `database/` → `rds`
   - `monitoring/` → `cloudwatch`
2. **El orquestador `main.tf` vive en cada entorno** (`environments/dev/`), no
   en la raíz de `infraestructure/`. La raíz solo contiene `modules/` y
   `environments/`.
3. **`apply` solo lo ejecuta el humano o un paso explícito fuera de los agentes.**
4. **Emulación local obligatoria** con Floci/LocalStack (`is_local = true`).

## Consecuencias
- (+) Escalabilidad: añadir un recurso nuevo = saber dónde va.
- (+) Entornos aislados: cada uno con su propio backend/estado/tfvars.
- (+) Gates de calidad replicables entre entornos.
- (-) Requiere orden de instanciación explícito en `main.tf`.
- (-) RDS/EC2 tienen límites en el emulador.
