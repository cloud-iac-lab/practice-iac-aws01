# Spec 002 — Landing Zone Profesional & Sistema de Inventariado

> **Estado**: Aprobado ✅
> **Autor**: architect
> **Fecha**: 2026-11-04
> **Objetivo**: Implementar una arquitectura de Zero Trust con segmentación de 4 capas y una app fullstack de inventariado.

## 1. Segmentación de Red (Mínimo Privilegio)
- **VPC**: 10.0.0.0/16 (1 AZ: us-east-1a)
- **Capas (Subnets)**:
    - **Public (ALB)**: 10.0.1.0/24. Entrada desde Internet.
    - **Compute (EC2)**: 10.0.2.0/24. Solo tráfico desde ALB (Puerto 80).
    - **Data (RDS)**: 10.0.3.0/24. Solo tráfico desde Compute (Puerto 3306).
    - **Endpoints**: 10.0.4.0/24. Para VPC Endpoints (SSM, CloudWatch).

## 2. Seguridad & Acceso
- **Security Groups**: Encadenados (ALB -> EC2 -> RDS).
- **SSH (22)**: Bloqueado. Acceso exclusivo vía **AWS Systems Manager (SSM)**.
- **VPC Endpoints**: Interface endpoints para `ssm`, `ssmmessages`, `ec2messages`, `logs`, `cloudwatch`.

## 3. Modelo de Datos (Inventariado 3NF)
- Tablas: `categorias`, `proveedores`, `productos`, `stock`.
- Relaciones: FKs estrictas para integridad referencial.

## 4. Aplicación (Node.js + React)
- **Backend**: API Express conectada a RDS MySQL.
- **Frontend**: SPA en React (Vite) servida por Node.
- **Despliegue**: User Data automatizado para instalación de dependencias y arranque.

## 5. Orden de Implementación
1. `networking/vpc` (4 capas)
2. `networking/endpoints` (Interface endpoints para SSM)
3. `database/rds` (Esquema 3NF)
4. `networking/alb`
5. `compute/ec2` (SSM Profile + NodeApp)
6. `monitoring/cloudwatch`
