#!/bin/bash

# Script pour construire le JAR avant le déploiement Railway
echo "🔨 Construction du JAR pour Railway..."

# Vérifier que Maven est installé
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven n'est pas installé"
    exit 1
fi

# Construire le JAR
echo "📦 Construction du JAR..."
mvn clean package -DskipTests

# Vérifier que le JAR existe
if [ ! -f "target/foo-bar-quix-1.0.0.jar" ]; then
    echo "❌ Le JAR n'a pas été créé"
    exit 1
fi

echo "✅ JAR construit avec succès: target/foo-bar-quix-1.0.0.jar"
echo "🚀 Prêt pour le déploiement Railway!"
