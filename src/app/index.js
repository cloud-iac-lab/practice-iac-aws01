const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Configuración Pool de Conexión (usando variables inyectadas por Terraform)
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// GET /productos - Lista productos con su categoría y stock
app.get('/productos', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT p.nombre, p.sku, c.nombre as categoria, s.cantidad
      FROM productos p
      JOIN categorias c ON p.categoria_id = c.id
      JOIN stock s ON p.id = s.producto_id
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /stock - Consulta rápida de cantidades por SKU
app.get('/stock', async (req, res) => {
  const { sku } = req.query;
  try {
    const [rows] = await pool.query(`
      SELECT p.nombre, s.cantidad
      FROM productos p
      JOIN stock s ON p.id = s.producto_id
      WHERE p.sku = ?
    `, [sku]);
    res.json(rows[0] || { message: 'Producto no encontrado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /productos - Registro simplificado (PoC)
app.post('/productos', async (req, res) => {
  const { nombre, sku, precio, categoria_id, proveedor_id } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO productos (nombre, sku, precio, categoria_id, proveedor_id) VALUES (?, ?, ?, ?, ?)',
      [nombre, sku, precio, categoria_id, proveedor_id]
    );
    res.json({ id: result.insertId, status: 'success' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Inventory App running on port ${PORT}`);
});
