# MCP: Floci / LocalStack

Integración del emulador local de AWS para que los agentes consulten **estado
real** sin depender solo de `terraform state`.

## Requisitos
- Floci/LocalStack corriendo en `http://localhost:4566`.
- Emulador compatible con AWS CLI.

## Uso desde un agente
```bash
# Listar buckets creados en el emulador
aws --endpoint-url=http://localhost:4566 s3 ls

# Consultar recursos de red
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
aws --endpoint-url=http://localhost:4566 rds describe-db-instances
aws --endpoint-url=http://localhost:4566 elbv2 describe-load-balancers
aws --endpoint-url=http://localhost:4566 route53 list-hosted-zones
aws --endpoint-url=http://localhost:4566 cloudwatch list-metrics
```

## Notas
- Usar `--endpoint-url=http://localhost:4566` **siempre** en local para no apuntar a AWS real.
- Credenciales dummy: `AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test`.
- El `validator` puede usar estas consultas para confirmar que el `plan`/`apply`
  refleja el estado real del emulador.

## Config MCP (opcional)
Si se usa el servidor MCP de LocalStack, registrar el `mcp` correspondiente en
`.opencode/opencode.json`. Por ahora se documenta el uso vía AWS CLI para
mantener la dependencia mínima.
