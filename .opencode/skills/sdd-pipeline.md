---
name: sdd-pipeline
description: Receta del flujo SDD obligatorio del proyecto. Orden exacto architect → implementer → validator → reviewer.
---

# Skill: SDD Pipeline

## Cuándo usar
Siempre que se quiera agregar o modificar infraestructura. Este es el flujo
**obligatorio**. No se puede saltar ninguna fase.

## Fases

### 1. Architect
- Crea/actualiza el spec en `specs/` y el ADR en `memory/decisions/`.
- **Herramientas**: `read`, `write`, `edit` (solo en `specs/`, `memory/`).

### 2. Implementer
- Escribe los `.tf` en `infraestructure/` siguiendo el spec.
- **Permitido**: `terraform init`, `terraform validate`, `terraform fmt`.
- **Prohibido**: `apply`, `destroy`.

### 3. Validator
- Corre la pipeline completa desde `infraestructure/environments/dev/`:
  `fmt → init → validate → tflint → checkov → plan`.
- Si algo falla → **se detiene** y reporta. No pasa a Reviewer.

### 4. Reviewer
- Revisa contra el spec + ADR, verifica skips justificados en `MEMORY.md`.
- Actualiza `memory/MEMORY.md` con aprendizajes.
- Aprueba o rechaza. **Solo lectura** del código.

## Nota crítica
`terraform apply` **nunca** lo ejecuta un agente. Lo ejecuta el humano o un paso
explícito fuera del flujo de agentes.
