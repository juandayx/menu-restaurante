# Contenedor 2: base de datos
# Imagen oficial con versión fija. El script init.sql queda DENTRO de la imagen,
# así el pipeline de Jenkins puede construirla sin depender de rutas del equipo.
FROM postgres:16.4-alpine

# PostgreSQL ejecuta automáticamente los .sql de esta carpeta la primera vez
COPY init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 5432
