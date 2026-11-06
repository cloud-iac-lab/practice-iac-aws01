# ADR-0002 — Implementación de Landing Zone y Zero Trust

- **Estado**: Aceptada
- **Fecha**: 2026-11-04
- **Autores**: architect

## Contexto
Se requiere elevar el estándar de seguridad y organización del proyecto2. El diseño inicial era demasiado simple. Se busca simular un entorno productivo real donde el acceso SSH no existe y el tráfico está estrictamente segmentado.

## Decisión
1.  **Segmentación en 4 capas**: Public, Compute, Data, Endpoints.
2.  **Eliminación de SSH**: Uso de SSM para gestión remota.
3.  **VPC Endpoints**: El tráfico hacia servicios AWS no sale a Internet.
4.  **Modelo 3NF**: Normalización de base de datos de inventariado.

## Consecuencias
- (+) Máxima seguridad: un compromiso en la capa de ALB no da acceso directo a la DB.
- (+) Gestión moderna: SSM elimina la fatiga de manejar llaves `.pem`.
- (+) Menor superficie de ataque: sin IPs públicas en Compute o Data.
- (-) Mayor complejidad en el código Terraform (más subnets, SGs y endpoints).
- (-) Mayor tiempo de arranque en Floci por el despliegue de la app Node.
