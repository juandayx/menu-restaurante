-- Contenedor 2: base de datos PostgreSQL
-- Este script se ejecuta automáticamente la primera vez que se crea el volumen.

CREATE TABLE IF NOT EXISTS platos (
  id          SERIAL PRIMARY KEY,
  nombre      VARCHAR(100)  NOT NULL,
  descripcion TEXT          DEFAULT '',
  precio      INTEGER       NOT NULL CHECK (precio >= 0),
  creado_en   TIMESTAMP     DEFAULT NOW()
);

INSERT INTO platos (nombre, descripcion, precio) VALUES
  ('Bandeja paisa', 'Frijoles, arroz, chicharrón, carne molida, huevo, plátano y arepa', 32000),
  ('Ajiaco santafereño', 'Con pollo, mazorca, alcaparras y crema de leche', 28000),
  ('Limonada de coco', 'Bebida fría de la casa', 9000);
