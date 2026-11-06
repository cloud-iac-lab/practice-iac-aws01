# Instrucciones para Agentes (Terraform AWS + Floci)

## Estructura del Repositorio
- `infraestructure/environments/dev/` — Punto de entrada Terraform (root module). **Aquí se ejecutan los comandos de ciclo de vida.**
- `infraestructure/modules/` — Módulos reutilizables agrupados por dominio: `networking/`, `compute/`, `database/`, `monitoring/`.
- `specs/` — Especificaciones SDD (el "por qué" antes del "cómo").
- `memory/` — Decisiones (ADRs) y aprendizajes persistentes del proyecto.
- `.opencode/` — Configuración de agentes, skills y MCP.

## Comandos Clave
Ejecutar **siempre** desde `infraestructure/environments/dev/`:
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply` — **solo humano o paso explícito, nunca un agente**

Desde la raíz del proyecto:
- `terraform fmt -recursive`
- `tflint` (usa `.tflint.hcl`)
- `checkov -d .`
- `pre-commit run --all-files`

## Emulación Local (Floci / LocalStack :4566)
- `terraform.tfvars` usa `is_local = true` → endpoint `http://localhost:4566`.
- `provider.tf` inyecta credenciales dummy (`test`/`test`) y omite la validación de credenciales/metadata cuando `is_local = true`. **No usar credenciales reales de AWS en local.**

## Flujo SDD (obligatorio)
```
architect (spec) → implementer (.tf) → validator (fmt→validate→tflint→checkov→plan) → reviewer (aprueba + MEMORY.md)
```
- Los agentes **nunca** ejecutan `terraform apply`.
- Todo `#checkov:skip` debe estar **justificado** en `memory/MEMORY.md`.

## Quirks de Floci / LocalStack
- **EC2**: la creación de instancias es limitada (no hay kernel real). Validar con `plan`; `apply` puede degradar.
- **RDS**: soportado pero lento; algunas features (Multi-AZ, snapshots cross-region) requieren LocalStack Pro.
- **VPC, Route53, ALB, CloudWatch**: soporte OSS completo.
- Los módulos se instancian en orden de dependencia: `networking → database → compute → alb → route53 → monitoring`.
