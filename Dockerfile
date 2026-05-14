# ================================
# ETAPA 1: Builder
# Instala todas las dependencias (incluidas las de desarrollo)
# ================================
FROM node:18-alpine AS builder

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar archivos de dependencias primero (aprovecha caché de Docker)
COPY package*.json ./

# Instalar todas las dependencias (incluyendo devDependencies)
RUN npm install

# Copiar el resto del código fuente
COPY . .

# ================================
# ETAPA 2: Production
# Solo copia lo necesario, sin devDependencies
# ================================
FROM node:18-alpine AS production

# Crear usuario no root por seguridad (mínimo privilegio)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm install --omit=dev && npm cache clean --force

# Copiar el código fuente desde la etapa builder
COPY --from=builder /app/server.js ./

# Cambiar propietario de los archivos al usuario no root
RUN chown -R appuser:appgroup /app

# Cambiar al usuario no root
USER appuser

# Exponer el puerto que usa Express
EXPOSE 3000

# Comando para iniciar el servidor
CMD ["node", "server.js"]