# Dockerfile simple et stable
FROM openjdk:11-jre-slim

WORKDIR /app

# Copier le JAR
COPY target/foo-bar-quix-1.0.0.jar app.jar

# Exposer le port
EXPOSE 8080

# Lancer l'application
CMD ["java", "-jar", "app.jar"]