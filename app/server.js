// Contenedor 1: aplicación web (Node.js + Express)
// Se conecta al contenedor 2 (PostgreSQL) usando el NOMBRE DEL SERVICIO "db",
// que Docker resuelve dentro de la red propia del proyecto.

const express = require("express");
const path = require("path");
const { Pool } = require("pg");

// Toda la configuración llega por variables de entorno (nada de claves en el código)
const pool = new Pool({
  host: process.env.DB_HOST,         // "db" -> nombre del servicio en docker-compose
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// Estado de la conexión entre contenedores
app.get("/health", async (req, res) => {
  try {
    const r = await pool.query("SELECT version()");
    res.json({
      estado: "ok",
      app: "contenedor app",
      conectado_a: process.env.DB_HOST,
      base_de_datos: r.rows[0].version.split(" on ")[0],
    });
  } catch (err) {
    res.status(500).json({ estado: "error", detalle: err.message });
  }
});

// LEER: lista los platos guardados en la base de datos
app.get("/api/platos", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id, nombre, descripcion, precio, creado_en FROM platos ORDER BY id"
    );
    res.json(r.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GUARDAR: inserta un plato nuevo en la base de datos
app.post("/api/platos", async (req, res) => {
  const { nombre, descripcion, precio } = req.body || {};
  if (!nombre || precio === undefined || precio === "" || isNaN(Number(precio))) {
    return res.status(400).json({ error: "Nombre y precio (número) son obligatorios" });
  }
  try {
    const r = await pool.query(
      "INSERT INTO platos (nombre, descripcion, precio) VALUES ($1, $2, $3) RETURNING *",
      [nombre, descripcion || "", Number(precio)]
    );
    res.status(201).json(r.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ELIMINAR: borra un plato
app.delete("/api/platos/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM platos WHERE id = $1", [req.params.id]);
    res.status(204).end();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = Number(process.env.APP_PORT || 3000);
app.listen(PORT, () => {
  console.log(`App escuchando en el puerto ${PORT}, base de datos en host "${process.env.DB_HOST}"`);
});
