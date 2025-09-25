#!/bin/bash

# Script pour déployer l'application en local avec accès public
# Usage: ./deploy-local.sh

set -e

APP_NAME="foo-bar-quix"
LOCAL_PORT=8080
PUBLIC_PORT=8081

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "🚀 Déploiement local de $APP_NAME"

# 1. Arrêter l'ancienne version
log_info "Arrêt de l'ancienne version..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

# 2. Construire l'image si nécessaire
if ! docker images | grep -q $APP_NAME; then
    log_info "Construction de l'image Docker..."
    mvn clean package -DskipTests
    docker build -f Dockerfile.working -t $APP_NAME .
fi

# 3. Lancer l'application
log_info "Lancement de l'application sur le port $PUBLIC_PORT..."
docker run -d -p $PUBLIC_PORT:8080 --name $APP_NAME $APP_NAME

# 4. Attendre le démarrage
log_info "Attente du démarrage..."
sleep 10

# 5. Vérifier que ça fonctionne
if curl -f http://localhost:$PUBLIC_PORT/actuator/health > /dev/null 2>&1; then
    log_info "✅ Application lancée avec succès!"
    log_info "🌐 URL locale: http://localhost:$PUBLIC_PORT"
    log_info "🔍 Test API: curl http://localhost:$PUBLIC_PORT/api/transform/15"
    log_info "📊 Health Check: curl http://localhost:$PUBLIC_PORT/actuator/health"
    
    log_info ""
    log_info "🌍 Pour rendre l'application accessible publiquement:"
    log_info "1. Installez ngrok: https://ngrok.com/download"
    log_info "2. Lancez: ngrok http $PUBLIC_PORT"
    log_info "3. Utilisez l'URL fournie par ngrok"
    
else
    log_error "❌ L'application n'a pas démarré correctement"
    log_info "Vérification des logs..."
    docker logs $APP_NAME
    exit 1
fi

log_info "🎉 Déploiement local terminé!"
