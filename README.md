# Menú del Restaurante – Docker con dos contenedores

Proyecto de la Entrega 1 del módulo de Integración Continua (Politécnico Grancolombiano).

Es un menú digital de restaurante que funciona en **dos contenedores comunicados entre sí**:

| Servicio | Contenedor | Papel | Imagen |
|---|---|---|---|
| `app` | `menu-app` | Aplicación web y API (Node.js + Express) | Dockerfile propio sobre `node:20.18-alpine` |
| `db` | `menu-db` | Base de datos | `postgres:16.4-alpine` con volumen `datos-menu` |

La app se conecta a la base de datos usando el **nombre del servicio `db`** dentro de la red propia `red-menu`, no `localhost` ni una IP fija.

## Estructura

```
menu-restaurante/
├── app/                    # Contenedor 1: aplicación
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── package.json
│   ├── package-lock.json
│   ├── server.js
│   └── public/index.html
├── db/                     # Contenedor 2: base de datos
│   └── init.sql
├── .github/workflows/ci.yml  # Pipeline de GitHub Actions
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

## Requisitos

- Docker Desktop (con Docker Compose)
- Git

## Cómo levantar los contenedores

```bash
# 1. Clonar el repositorio
git clone https://github.com/USUARIO/menu-restaurante.git
cd menu-restaurante

# 2. Crear el archivo de variables a partir del ejemplo
cp .env.example .env        # en Windows (PowerShell): copy .env.example .env

# 3. Construir y levantar
docker compose up --build -d

# 4. Abrir en el navegador
#    http://localhost:3000
```

## Comandos útiles

```bash
docker compose ps                         # ver los contenedores
docker ps                                 # ver contenedores en ejecución
docker network inspect menu-restaurante_red-menu   # ver la red y los dos contenedores conectados
docker compose logs app                   # ver los logs de la app
docker compose down                       # apagar (los datos se conservan)
docker compose down -v                    # apagar y borrar el volumen de datos
```

## Prueba de comunicación (ida y vuelta)

```bash
# Guardar un plato (app -> db)
curl -X POST http://localhost:3000/api/platos -H "Content-Type: application/json" -d "{\"nombre\":\"Sancocho\",\"descripcion\":\"De gallina\",\"precio\":25000}"

# Leerlo de vuelta (db -> app)
curl http://localhost:3000/api/platos

# Estado de la conexión
curl http://localhost:3000/health
```

También se puede probar desde el navegador: agregar un plato en el formulario y ver que aparece en la lista.

## Endpoints

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/` | Página del menú |
| GET | `/health` | Estado de la conexión con la base de datos |
| GET | `/api/platos` | Lista los platos |
| POST | `/api/platos` | Guarda un plato (`nombre`, `descripcion`, `precio`) |
| DELETE | `/api/platos/:id` | Elimina un plato |

## Integración continua

El archivo `.github/workflows/ci.yml` se ejecuta en cada push y pull request. Construye las imágenes, levanta los contenedores y prueba que se pueda guardar y leer un plato.
