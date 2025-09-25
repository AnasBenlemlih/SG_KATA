#!/bin/bash

# Script de déploiement sur serveur
# Usage: ./deploy-server.sh [server-ip] [github-token]

set -e

# Configuration
SERVER_IP=${1:-"your-server-ip"}
GITHUB_TOKEN=${2:-"your-github-token"}
APP_NAME="foo-bar-quix"
REGISTRY="ghcr.io"
IMAGE_NAME="anasbenlemlih/sg_kata"

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

# Vérification des paramètres
if [ "$SERVER_IP" = "your-server-ip" ]; then
    log_error "Veuillez fournir l'IP du serveur"
    echo "Usage: $0 <server-ip> [github-token]"
    exit 1
fi

log_info "Déploiement de $APP_NAME sur $SERVER_IP"

# 1. Se connecter au serveur et arrêter l'ancienne version
log_info "Arrêt de l'ancienne version..."
ssh root@$SERVER_IP "docker stop $APP_NAME 2>/dev/null || true"
ssh root@$SERVER_IP "docker rm $APP_NAME 2>/dev/null || true"

# 2. Télécharger la nouvelle image
log_info "Téléchargement de la nouvelle image..."
if [ -n "$GITHUB_TOKEN" ]; then
    ssh root@$SERVER_IP "echo '$GITHUB_TOKEN' | docker login $REGISTRY -u anasbenlemlih --password-stdin"
fi
ssh root@$SERVER_IP "docker pull $REGISTRY/$IMAGE_NAME:latest"

# 3. Lancer la nouvelle version
log_info "Lancement de la nouvelle version..."
ssh root@$SERVER_IP "docker run -d -p 8080:8080 --name $APP_NAME --restart unless-stopped $REGISTRY/$IMAGE_NAME:latest"

# 4. Vérifier le déploiement
log_info "Vérification du déploiement..."
sleep 10

if ssh root@$SERVER_IP "curl -f http://localhost:8080/actuator/health > /dev/null 2>&1"; then
    log_info "✅ Déploiement réussi!"
    log_info "🌐 Application accessible sur: http://$SERVER_IP:8080"
    log_info "🔍 Test API: curl http://$SERVER_IP:8080/api/transform/15"
else
    log_error "❌ Le déploiement a échoué"
    ssh root@$SERVER_IP "docker logs $APP_NAME"
    exit 1
fi

log_info "🎉 Déploiement terminé avec succès!"
