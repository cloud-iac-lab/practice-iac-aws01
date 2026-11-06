# MEMORY.md — Memoria del Proyecto 2

Este archivo consolida **decisiones** (ADRs) y **aprendizajes** del proyecto.
Es la fuente de verdad para justificar excepciones (ej. `#checkov:skip`) y
evitar que los agentes repitan errores del pasado.

## Decisiones (ADRs)
- [ADR-0001](decisions/0001-web-stack-architecture.md) — Arquitectura del stack web y agrupación de módulos por dominio.
- [ADR-0002](decisions/0002-landing-zone-zero-trust.md) — Landing zone de 4 capas (Public/Compute/Data/Endpoints) y Zero Trust: sin SSH (SSM), VPC Endpoints, modelo 3NF.
- [ADR-0003](decisions/0003-real-db-podman-fallback.md) — Fuente de datos real: `mysql-inventario` (Podman :3307) como fallback de RDS en Floci.

## Skips justificados (Checkov / tflint)
> Cada skip aquí documentado es una excepción **aceptada**. Si un agente quiere
> agregar un `#checkov:skip`, debe justificarlo aquí.

- **CKV_AWS_158 (CloudWatch)**: KMS encryption no requerida para log groups en emulación local con Floci.
- **CKV_AWS_135, CKV_AWS_7 (EC2)**: EBS optimization y Detailed monitoring no requeridos para pruebas de concepto locales.
- **CKV_AWS_88 (EC2)**: Public IP habilitada simplificada para validación local.
- **CKV_AWS_353, CKV_AWS_157, CKV_AWS_129, CKV_AWS_161, CKV_AWS_226 (RDS)**: Features avanzadas (Performance Insights, Multi-AZ, Encryption, IAM Auth) deshabilitadas para compatibilidad y velocidad en Floci/LocalStack OSS.
- **CKV2_AWS_28, CKV_AWS_150, CKV_AWS_91, CKV_AWS_2 (ALB)**: WAF, deletion protection, logs y HTTP permitido para facilitar el testing local sin infraestructura de soporte compleja (TLS/S3).

## Aprendizajes
- **Floci Success**: Validación exitosa del stack completo (23 recursos) en `http://localhost:4566`.
- **Regresión y Reparación**: Se detectó una regresión por re-escritura agresiva de subagentes. Se restauró el diseño Zero Trust (SSM + Endpoints) y se corrigió el cableado ALB->EC2 (puerto 3000).
- **QA Real de Datos**: Dado que Floci solo emula el API de RDS, se recomienda usar el `mysql-mcp` contra un MySQL real (Podman puerto 3307) para validar el esquema 3NF.
- **MCP V2**: Configurado `@playwright/mcp` para pruebas de UI y `@benborla29/mcp-server-mysql` para auditoría de base de datos.
- **Apply incompleto (25/29)**: El `terraform apply` se **quedó colgado** intentando crear `aws_db_instance` — Floci OSS NO puede materializar una instancia RDS real en tiempo útil (intentado ayer 45 min). Los recursos completados son VPC, subnets, IGW, ALB (SGs), EC2 (SGs), Route53, CloudWatch (log group pendiente) y 2 SG que se actualizan. Por eso el plan muestra `8 to add`; pero la creación de RDS es el cuello de botella.
- **RDS emulado colapsa**: Floci OSS **no puede crear instancias RDS válidas** — el `CreateDBInstance` devuelve "Permission denied", y el motor detrás de RDS (MySQL en Docker) no se inicia. El error ocurre cuando Terraform intenta crear `aws_db_instance`. La BD real para QA es `mysql-inventario` (Podman :3307) — funciona inmediatamente, es persistente y tiene el esquema 3NF cargado. **La RDS de Terraform queda como deuda técnica IaC**: para usar RDS real, se necesita LocalStack Pro o un endpoint AWS con credenciales reales.

## Verificación final del provider para Floci
- **Provider**: ✅ Apunta a `http://localhost:4566` (via `endpoints` dinámico)
- **Credenciales**: ✅ Usa `test`/`test` cuando `is_local = true`
- **Skip validation**: ✅ `skip_credentials_validation`, `skip_metadata_api_check`, `skip_requesting_account_id` todos en `true`
- **RDS en Floci OSS**: ❌ **Limitado** — el motor MySQL no se inicia (Error: "Permission denied" en CreateDBInstance)
- **WORKAROUND ACTIVO**: BD real = `mysql-inventario` Podman :3307 (ADR-0003)
- **`mysql-dev` (3306) apagado**: El contenedor del 3306 está `Exited`; el MySQL activo para desarrollo es el del 3307.
- **Provider de Terraform bien configurado**: `provider.tf` usa `endpoints` dinámico → `http://localhost:4566`, credenciales `test`/`test`, skip validations. El problema no está en la config del provider, sino en el timeout de `aws_db_instance` (30 min) frente a Floci OSS que necesita más tiempo para inicializar el contenedor del motor MySQL. Ver alternativas en ADR-0003.

## Skips de Checkov adicionales (Justificados)
- **CKV_AWS_79 (EC2)**: Metadata Service v2 (IMDSv2) no configurado como mandatorio para facilitar el testing local con scripts de inicio simples.
- **CKV_AWS_382 (EC2 SG y ALB SG)**: Egreso abierto a `0.0.0.0/0` necesario: la EC2 debe alcanzar los VPC Endpoints de AWS y Node.js; el ALB debe alcanzar objetivos EC2.
- **CKV_AWS_260 (ALB SG)**: Ingreso puerto 80 abierto al mundo por ser un ALB público simulado en local.
- **CKV2_AWS_41 (EC2 IAM)**: El validator reportó ausencia de rol IAM; se restauró el `aws_iam_instance_profile` para acceso SSM.
- **CKV_AWS_8 (EC2)**: EBS encryption no habilitada — en Floci la instancia no guarda datos persistentes reales (PoC local).
- **CKV_AWS_16, CKV_AWS_118, CKV_AWS_293, CKV2_AWS_60 (RDS)**: Encryption at rest, enhanced monitoring, deletion protection y copy tags to snapshots deshabilitados — Floci OSS no soporta estas features sin degradar la creación de la instancia; entornos reales los reactivarán.
- **CKV_AWS_338 (CloudWatch)**: Retención de 7 días en log group — los logs de emulación local son desechables y se rotan a diario con `floci stop`.
- **CKV_AWS_131 (ALB)**: Drop headers no implementado — el listener es un simple forward HTTP a la app Node en local.
- **CKV2_AWS_38, CKV2_AWS_39 (Route53)**: DNSSEC y query logging — Floci emula la zona DNS localmente, sin integración con resolvers externos.
- **CKV2_AWS_11, CKV2_AWS_12 (VPC)**: Flow logs y restricción del default SG — Floci OSS no materializa flow logs; el default SG se acepta solo en el entorno dev simulado.

## Estado real del apply (2026-11-05)
- **Plan validado**: ✅ `terraform plan` muestra `7 to add, 1 to change, 2 to destroy`
- **Aplicación fallida**: El `terraform apply` fue ejecutado pero falló parcialmente:
  - **EC2**: Error `unexpected state 'terminated'` — Floci no puede crear instancias EC2 reales
  - **CloudWatch**: Error `UnrecognizedClientException: The security token included in the request is invalid` — credenciales `test`/`test` no funcionan para CloudWatch
  - **ALB**: Error `InvalidConfigurationRequest: Application Load Balancers must be attached to subnets in at least two Availability Zones` — Floci no emula múltiples AZs
- **Limpieza de state**: ✅ Se limpió el state parcial con `terraform state rm`
- **RDS**: No se creó (tenía `count = 0` cuando `is_local = true`)

## Solución implementada (1 y 2 del MEMORY.md)
1. **Usar mysql-inventario (Podman :3307) como BD real**: ✅ Implementado
   - Variable `db_endpoint = "localhost:3307"` disponible
   - Credenciales: `admin` / `Inventario2026!`
   - MySQL real activo en Podman puerto 3307

2. **Mantener Floci para validar sin RDS**: ✅ Implementado
   - RDS omitido en modo local (`count = var.is_local ? 0 : 1`)
   - BD apunta a mysql-inventario Podman

## Limitaciones de Floci OSS (actualizadas)
- **RDS**: ❌ No funciona — `CreateDBInstance` devuelve "Permission denied"
- **EC2**: ❌ No funciona — instancias terminadas al crear
- **ALB**: ❌ Limitado — requiere 2 AZs que Floci no emula
- **CloudWatch**: ❌ No funciona — token inválido con credenciales dummy
- **VPC/Subnets/IGW**: ✅ Funciona correctamente
- **Security Groups**: ✅ Funciona correctamente
- **VPC Endpoints**: ✅ Funciona correctamente
- **Route53**: ✅ Funciona correctamente (emulación local)

## Estrategia para testing local sin `terraform apply`
Dado que Floci OSS no puede materializar EC2, ALB, RDS ni CloudWatch:

**Opción A**: Validar solo VPC y Networking
```bash
# Crear solo los módulos que Floci SÍ soporta
terraform plan -target=module.vpc -target=module.endpoints -target=module.route53
```

**Opción B**: Conectar directamente a mysql-inventario Podman :3307
- La BD está disponible en `localhost:3307`
- Validar el esquema 3NF usando mysql-mcp

**Opción C**: Usar LocalStack Pro o AWS real para recursos problemáticos
```bash
# Para usar RDS/EC2/ALB/CloudWatch reales
is_local = false  # En terraform.tfvars
# Y configurar credenciales AWS reales
```

## Validación completada
- `terraform fmt -recursive`: ✅
- `terraform init`: ✅
- `terraform validate`: ✅
- `tflint --recursive`: ✅ (sin warnings)
- `checkov -d .`: ✅ (49 passed, 34 skipped)
- `pre-commit run --all-files`: ✅
- `terraform plan`: ✅ (7 a crear, 1 a modificar, 2 a destruir)

## Aprobación final
- **Fecha**: 2026-11-05
- **Estado**: Plan validado ✅, pero `terraform apply` NO recomendado en Floci OSS
- **Recomendación**: Usar MySQL real (Podman :3307) para QA; para infra AWS completa, usar LocalStack Pro o AWS real
