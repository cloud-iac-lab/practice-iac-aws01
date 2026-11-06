# ADR-0003 — Fuente de datos real: `mysql-inventario` (Podman :3307) como fallback de RDS

- **Estado**: Aceptada
- **Fecha**: 2026-11-05
- **Autores**: architect / reviewer (confirmado por humano)

## Contexto
El `terraform apply` contra Floci quedó **incompleto** (21/29 recursos en estado;
faltan EC2, instancia RDS, ALB + listener, rutas, Route53 y monitoring). La causa
principal es que **Floci OSS no inicializa RDS en tiempo útil** — el motor MySQL
se levanta en Docker pero el endpoint tarda más de lo que Terraform espera.

**Clarificación**: Floci sí soporta RDS (MySQL/PostgreSQL reales en Docker), pero:
- **Floci OSS**: el motor se levanta en un contenedor Docker secundario; el `apply`
  de Terraform puede colgarse esperando a que el endpoint responda.
- **LocalStack OSS**: solo emula el API de RDS, SIN motor real por debajo.

Para validar el esquema 3NF y que la app Node funcione con datos reales, se
necesita una base MySQL real y persistente.

## Decisión
1. **Usar el contenedor `mysql-inventario` de Podman (puerto 3307)** como fuente
   de datos real para el QA de la app, mientras RDS en Floci queda como referencia
   de IaC (plan/apply de la infraestructura).
2. Credenciales de conexión: `root` / `rootpassword`, base `inventario_db`
   (esquema 3NF + seed ya cargados y verificados: 2 categorías, 2 productos, 1 stock).
3. La app (`src/app/index.js`) apunta a `DB_PORT=3307` en modo local, no al 3306
   por defecto (el `mysql-dev` del 3306 está apagado).
4. No bloquear el `apply` de Terraform por RDS: si la creación de `aws_db_instance`
   falla o se cuelga, se continúa con la BD de Podman y se documenta en el memory.

## Consecuencias
- (+) QA real de datos: el esquema 3NF se valida contra un MySQL real, no contra un emulador.
- (+) La app puede probarse de extremo a extremo sin depender de que RDS cree en Floci.
- (+) El contenedor `mysql-inventario` está disponible inmediatamente (`Up 19h`) vs RDS en Floci que puede tardar minutos o fallar.
- (-) Divergencia controlada: la infra RDS en Floci y la BD real (Podman) no comparten estado; la BD real es la fuente de datos de desarrollo.
- (-) Para un entorno real (AWS) habrá que conectar la app al endpoint del RDS real (variable `DB_HOST`/`DB_PORT`).

## Alternativas (no implementadas)
1. Levantar Floci, esperar a que RDS esté listo (`floci wait --services rds`), y luego `terraform apply`.
2. Usar LocalStack Community Edition con soporte RDS (requiere plan de pago).
3. Usar `aws_rds_cluster` (Aurora) en vez de `aws_db_instance` — a veces Floci gestiona Aurora más rápido.

## Cómo se conecta la app
```bash
DB_HOST=localhost DB_PORT=3307 DB_USER=root DB_PASS=rootpassword DB_NAME=inventario_db PORT=3000 node index.js
```
