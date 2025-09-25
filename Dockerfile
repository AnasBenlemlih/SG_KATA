# Multi-stage build pour optimiser la taille de l'image
FROM maven:3.8.6-openjdk-11 AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de configuration Maven
COPY pom.xml .
COPY src ./src

# Build de l'application
RUN mvn clean package -DskipTests

# Stage de production
FROM openjdk:17-jre-slim

# Installer les outils nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Définir le répertoire de travail
WORKDIR /app

# Copier le JAR depuis le stage de build
COPY --from=build /app/target/foo-bar-quix-1.0.0.jar app.jar

# Créer les répertoires nécessaires
RUN mkdir -p /app/input /app/output && \
    chown -R appuser:appuser /app

# Changer vers l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8080

# Variables d'environnement
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=docker

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Point d'entrée
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
