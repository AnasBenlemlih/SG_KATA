#!/bin/bash

# Script de configuration automatique du serveur
# Usage: ./setup-server.sh [server-ip] [github-token]

set -e

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

log_info "Configuration du serveur $SERVER_IP pour $APP_NAME"

# 1. Mise à jour du système
log_info "Mise à jour du système..."
ssh root@$SERVER_IP "apt update && apt upgrade -y"

# 2. Installation de Docker
log_info "Installation de Docker..."
ssh root@$SERVER_IP "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
ssh root@$SERVER_IP "systemctl start docker && systemctl enable docker"

# 3. Installation de curl (pour les tests)
log_info "Installation de curl..."
ssh root@$SERVER_IP "apt install -y curl"

# 4. Configuration du firewall
log_info "Configuration du firewall..."
ssh root@$SERVER_IP "ufw allow 22/tcp && ufw allow 8080/tcp && ufw --force enable"

# 5. Authentification GitHub Container Registry
if [ -n "$GITHUB_TOKEN" ]; then
    log_info "Configuration de l'authentification GitHub..."
    ssh root@$SERVER_IP "echo '$GITHUB_TOKEN' | docker login $REGISTRY -u anasbenlemlih --password-stdin"
fi

# 6. Arrêt de l'ancienne version (si elle existe)
log_info "Arrêt de l'ancienne version..."
ssh root@$SERVER_IP "docker stop $APP_NAME 2>/dev/null || true"
ssh root@$SERVER_IP "docker rm $APP_NAME 2>/dev/null || true"

# 7. Téléchargement de la nouvelle image
log_info "Téléchargement de l'image Docker..."
ssh root@$SERVER_IP "docker pull $REGISTRY/$IMAGE_NAME:latest"

# 8. Lancement de l'application
log_info "Lancement de l'application..."
ssh root@$SERVER_IP "docker run -d -p 8080:8080 --name $APP_NAME --restart unless-stopped $REGISTRY/$IMAGE_NAME:latest"

# 9. Attendre le démarrage
log_info "Attente du démarrage de l'application..."
sleep 15

# 10. Vérification
log_info "Vérification du déploiement..."
if ssh root@$SERVER_IP "curl -f http://localhost:8080/actuator/health > /dev/null 2>&1"; then
    log_info "✅ Déploiement réussi!"
    log_info "🌐 Application accessible sur: http://$SERVER_IP:8080"
    log_info "🔍 Test API: curl http://$SERVER_IP:8080/api/transform/15"
    log_info "📊 Health Check: curl http://$SERVER_IP:8080/actuator/health"
else
    log_error "❌ Le déploiement a échoué"
    log_info "Vérification des logs..."
    ssh root@$SERVER_IP "docker logs $APP_NAME"
    exit 1
fi

log_info "🎉 Configuration du serveur terminée avec succès!"
log_info "📝 Commandes utiles:"
log_info "  - Voir les logs: ssh root@$SERVER_IP 'docker logs $APP_NAME'"
log_info "  - Redémarrer: ssh root@$SERVER_IP 'docker restart $APP_NAME'"
log_info "  - Statut: ssh root@$SERVER_IP 'docker ps'"
