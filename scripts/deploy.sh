#!/bin/bash

# Script de déploiement automatisé pour Foo Bar Quix
# Usage: ./deploy.sh [environment] [version]
# Exemple: ./deploy.sh prod 1.0.0

set -e

# Configuration
ENVIRONMENT=${1:-dev}
VERSION=${2:-1.0.0}
APP_NAME="foo-bar-quix"
DOCKER_IMAGE="${APP_NAME}:${VERSION}"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if ! command -v java &> /dev/null; then
        log_error "Java n'est pas installé"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        log_error "Maven n'est pas installé"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    log_info "Tous les prérequis sont satisfaits"
}

# Build de l'application
build_application() {
    log_info "Build de l'application avec le profil ${ENVIRONMENT}..."
    
    mvn clean package -P${ENVIRONMENT} -DskipTests
    
    if [ $? -eq 0 ]; then
        log_info "Build réussi"
    else
        log_error "Échec du build"
        exit 1
    fi
}

# Build de l'image Docker
build_docker_image() {
    log_info "Construction de l'image Docker..."
    
    docker build -t ${DOCKER_IMAGE} .
    
    if [ $? -eq 0 ]; then
        log_info "Image Docker construite avec succès: ${DOCKER_IMAGE}"
    else
        log_error "Échec de la construction de l'image Docker"
        exit 1
    fi
}

# Déploiement en développement
deploy_dev() {
    log_info "Déploiement en mode développement..."
    
    # Arrêter les conteneurs existants
    docker-compose down 2>/dev/null || true
    
    # Démarrer les services
    docker-compose up -d
    
    log_info "Application déployée en mode développement"
    log_info "URL: http://localhost:8080"
    log_info "H2 Console: http://localhost:8080/h2-console"
}

# Déploiement en production
deploy_prod() {
    log_info "Déploiement en mode production..."
    
    # Créer les répertoires nécessaires
    mkdir -p logs input output
    
    # Arrêter les conteneurs existants
    docker-compose -f docker-compose.yml down 2>/dev/null || true
    
    # Démarrer les services
    docker-compose -f docker-compose.yml up -d
    
    # Attendre que l'application soit prête
    log_info "Attente du démarrage de l'application..."
    sleep 30
    
    # Vérifier la santé de l'application
    if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
        log_info "Application déployée avec succès en production"
        log_info "URL: http://localhost:8080"
        log_info "Monitoring: http://localhost:3000 (Grafana)"
        log_info "Métriques: http://localhost:9090 (Prometheus)"
    else
        log_error "L'application n'est pas accessible"
        exit 1
    fi
}

# Tests de santé
health_check() {
    log_info "Vérification de la santé de l'application..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
            log_info "Application en bonne santé"
            return 0
        fi
        
        log_info "Tentative $attempt/$max_attempts - Attente..."
        sleep 10
        ((attempt++))
    done
    
    log_error "L'application n'est pas accessible après $max_attempts tentatives"
    return 1
}

# Nettoyage
cleanup() {
    log_info "Nettoyage des ressources..."
    
    # Supprimer les images Docker non utilisées
    docker image prune -f
    
    # Nettoyer les volumes Docker non utilisés
    docker volume prune -f
}

# Fonction principale
main() {
    log_info "Début du déploiement de ${APP_NAME} v${VERSION} en mode ${ENVIRONMENT}"
    
    check_prerequisites
    build_application
    
    if [ "$ENVIRONMENT" = "dev" ] || [ "$ENVIRONMENT" = "docker" ]; then
        build_docker_image
        deploy_dev
    elif [ "$ENVIRONMENT" = "prod" ]; then
        build_docker_image
        deploy_prod
    else
        log_error "Environnement non supporté: ${ENVIRONMENT}"
        log_info "Environnements supportés: dev, docker, prod"
        exit 1
    fi
    
    health_check
    cleanup
    
    log_info "Déploiement terminé avec succès!"
}

# Gestion des signaux
trap cleanup EXIT

# Exécution
main "$@"
