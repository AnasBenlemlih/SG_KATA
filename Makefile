# Makefile pour automatiser les tâches de développement et déploiement

.PHONY: help build test clean docker-build docker-run docker-compose-up docker-compose-down deploy-dev deploy-prod

# Variables
APP_NAME = foo-bar-quix
VERSION = 1.0.0
DOCKER_IMAGE = $(APP_NAME):$(VERSION)

# Couleurs pour les logs
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## Afficher l'aide
	@echo "$(GREEN)Foo Bar Quix - Makefile$(NC)"
	@echo ""
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

build: ## Compiler l'application
	@echo "$(GREEN)Compilation de l'application...$(NC)"
	mvn clean package -DskipTests

build-docker: ## Compiler avec profil Docker
	@echo "$(GREEN)Compilation avec profil Docker...$(NC)"
	mvn clean package -Pdocker -DskipTests

test: ## Exécuter les tests
	@echo "$(GREEN)Exécution des tests...$(NC)"
	mvn test

test-integration: ## Exécuter les tests d'intégration
	@echo "$(GREEN)Exécution des tests d'intégration...$(NC)"
	mvn verify

clean: ## Nettoyer le projet
	@echo "$(GREEN)Nettoyage du projet...$(NC)"
	mvn clean
	docker system prune -f

docker-build: ## Construire l'image Docker
	@echo "$(GREEN)Construction de l'image Docker...$(NC)"
	docker build -t $(DOCKER_IMAGE) .

docker-run: ## Exécuter l'image Docker
	@echo "$(GREEN)Exécution de l'image Docker...$(NC)"
	docker run -p 8080:8080 -v $(PWD)/input:/app/input -v $(PWD)/output:/app/output $(DOCKER_IMAGE)

docker-compose-up: ## Démarrer tous les services avec Docker Compose
	@echo "$(GREEN)Démarrage des services...$(NC)"
	docker-compose up -d

docker-compose-down: ## Arrêter tous les services
	@echo "$(GREEN)Arrêt des services...$(NC)"
	docker-compose down

docker-compose-logs: ## Afficher les logs des services
	@echo "$(GREEN)Logs des services:$(NC)"
	docker-compose logs -f

deploy-dev: ## Déploiement en développement
	@echo "$(GREEN)Déploiement en développement...$(NC)"
	./scripts/deploy.sh dev

deploy-prod: ## Déploiement en production
	@echo "$(GREEN)Déploiement en production...$(NC)"
	./scripts/deploy.sh prod $(VERSION)

health-check: ## Vérifier la santé de l'application
	@echo "$(GREEN)Vérification de la santé de l'application...$(NC)"
	@curl -f http://localhost:8080/actuator/health || echo "$(RED)Application non accessible$(NC)"

test-api: ## Tester l'API
	@echo "$(GREEN)Test de l'API...$(NC)"
	@curl -s http://localhost:8080/api/transform/15 | jq . || echo "$(RED)API non accessible$(NC)"

test-batch: ## Tester le traitement par lot
	@echo "$(GREEN)Test du traitement par lot...$(NC)"
	@curl -X POST http://localhost:8080/api/batch/process || echo "$(RED)Batch non accessible$(NC)"

monitoring: ## Ouvrir les interfaces de monitoring
	@echo "$(GREEN)Interfaces de monitoring:$(NC)"
	@echo "  - Application: http://localhost:8080/actuator/health"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - H2 Console: http://localhost:8080/h2-console"

setup: ## Configuration initiale du projet
	@echo "$(GREEN)Configuration initiale...$(NC)"
	@mkdir -p input output logs
	@echo "1\n3\n5\n7\n9\n15\n33\n51\n53" > input/numbers.txt
	@echo "$(GREEN)Configuration terminée$(NC)"

dev: build docker-compose-up health-check ## Démarrage rapide en développement
	@echo "$(GREEN)Environnement de développement prêt!$(NC)"
	@echo "  - API: http://localhost:8080"
	@echo "  - Monitoring: http://localhost:3000"

prod: build-docker docker-compose-up health-check ## Démarrage en production
	@echo "$(GREEN)Environnement de production prêt!$(NC)"
	@echo "  - API: http://localhost:8080"
	@echo "  - Monitoring: http://localhost:3000"

# Règle par défaut
.DEFAULT_GOAL := help
