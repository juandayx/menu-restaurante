# Contenedor 1: aplicación web del menú
# Imagen base oficial con versión fija (no "latest")
FROM node:20.18-alpine

# Carpeta de trabajo dentro del contenedor
WORKDIR /app

# Primero solo los archivos de dependencias (aprovecha la caché de Docker)
COPY package.json package-lock.json ./

# Instala las dependencias exactas del package-lock, sin las de desarrollo
RUN npm ci --omit=dev

# Copia el resto del código (lo que está en .dockerignore no se copia)
COPY . .

# Ejecuta como usuario sin privilegios (buena práctica de seguridad)
USER node

# Puerto en el que escucha la aplicación
EXPOSE 3000

# Comando de inicio
CMD ["node", "server.js"]
