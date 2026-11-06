-- Esquema de Inventariado 3NF (MySQL)
CREATE DATABASE IF NOT EXISTS inventario_db;
USE inventario_db;

CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    contacto VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    categoria_id INT,
    proveedor_id INT,
    precio DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE IF NOT EXISTS stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT UNIQUE,
    cantidad INT DEFAULT 0,
    ubicacion_bodega VARCHAR(100),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Seed de datos iniciales
INSERT INTO categorias (nombre) VALUES ('Electronica'), ('Hogar');
INSERT INTO proveedores (nombre, contacto) VALUES ('Tech Corp', 'tech@example.com');
INSERT INTO productos (nombre, sku, categoria_id, proveedor_id, precio)
VALUES ('Laptop Pro 2026', 'LT-2026-001', 1, 1, 1200.00);
INSERT INTO stock (producto_id, cantidad, ubicacion_bodega) VALUES (1, 50, 'A1-Z4');
