#!/usr/bin/env bash
# Prueba de integración: levanta los dos contenedores y verifica que
# la app se comunica con la base de datos usando el NOMBRE DEL SERVICIO "db".
# Si cualquier verificación falla, el script termina con error y el build falla.
set -euo pipefail

echo "==> Levantando los contenedores"
docker compose up -d

echo "==> Esperando a que la app responda en /health"
ok=0
for i in $(seq 1 30); do
  if docker compose exec -T app wget -qO- http://localhost:3000/health > health.json 2>/dev/null; then
    ok=1; break
  fi
  sleep 2
done
if [ "$ok" -ne 1 ]; then
  echo "ERROR: la app no respondió o no pudo conectarse a la base de datos"
  docker compose logs
  exit 1
fi
cat health.json; echo

echo "==> Prueba 1: la app está conectada al servicio 'db'"
grep -q '"estado":"ok"' health.json
grep -q '"conectado_a":"db"' health.json
echo "OK"

echo "==> Prueba 2: el nombre 'db' se resuelve dentro de la red de Docker"
docker compose exec -T app node -e "require('dns').lookup('db',(e,a)=>{if(e){console.error(e.message);process.exit(1)}console.log('db ->',a)})"
echo "OK"

echo "==> Prueba 3: ida y vuelta (guardar y leer un plato)"
NOMBRE="Plato Jenkins ${BUILD_NUMBER:-local}"
docker compose exec -T app wget -qO- \
  --header='Content-Type: application/json' \
  --post-data="{\"nombre\":\"${NOMBRE}\",\"descripcion\":\"Creado por el pipeline\",\"precio\":1234}" \
  http://localhost:3000/api/platos
echo
docker compose exec -T app wget -qO- http://localhost:3000/api/platos | grep -q "${NOMBRE}"
echo "OK: '${NOMBRE}' se guardó en PostgreSQL y se leyó de vuelta"

rm -f health.json
echo "==> Todas las pruebas pasaron"
