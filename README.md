# Proyecto 2 — Stack Web en AWS (Terraform + Floci)

Proyecto IaC de ejemplo con stack de red web completo, desarrollado bajo
buenas prácticas SDD (Spec-Driven Development) y validado localmente contra
**Floci/LocalStack** en el puerto `4566`.

## Stack

- **Networking**: VPC, subnets públicas/privadas, IGW, ALB, Route 53
- **Compute**: EC2
- **Database**: RDS (MySQL)
- **Monitoring**: CloudWatch (log groups + alarmas)

## Flujo SDD

```
architect → implementer → validator → reviewer
   (spec)      (.tf)      (gates)     (aprueba)
```

- `specs/` — especificaciones (por qué se hace)
- `memory/` — decisiones (ADRs) y aprendizajes
- `.opencode/agents/` — subagentes con roles por fase

## Comandos

Todos los comandos de ciclo de vida se ejecutan desde
`infraestructure/environments/dev/`:

```bash
cd infraestructure/environments/dev
terraform init
terraform validate
terraform plan
```

Para emulación local, `terraform.tfvars` trae `is_local = true` y apunta a
`http://localhost:4566`. **No uses credenciales reales de AWS** cuando
`is_local = true`.
