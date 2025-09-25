@echo off
REM Script de déploiement automatisé pour Foo Bar Quix (Windows)
REM Usage: deploy.bat [environment] [version]
REM Exemple: deploy.bat prod 1.0.0

setlocal enabledelayedexpansion

REM Configuration
set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

set VERSION=%2
if "%VERSION%"=="" set VERSION=1.0.0

set APP_NAME=foo-bar-quix
set DOCKER_IMAGE=%APP_NAME%:%VERSION%

REM Fonctions utilitaires
:log_info
echo [INFO] %~1
goto :eof

:log_warn
echo [WARN] %~1
goto :eof

:log_error
echo [ERROR] %~1
goto :eof

REM Vérification des prérequis
:check_prerequisites
call :log_info "Vérification des prérequis..."

java -version >nul 2>&1
if errorlevel 1 (
    call :log_error "Java n'est pas installé"
    exit /b 1
)

mvn -version >nul 2>&1
if errorlevel 1 (
    call :log_error "Maven n'est pas installé"
    exit /b 1
)

docker --version >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker n'est pas installé"
    exit /b 1
)

call :log_info "Tous les prérequis sont satisfaits"
goto :eof

REM Build de l'application
:build_application
call :log_info "Build de l'application avec le profil %ENVIRONMENT%..."

mvn clean package -P%ENVIRONMENT% -DskipTests
if errorlevel 1 (
    call :log_error "Échec du build"
    exit /b 1
)

call :log_info "Build réussi"
goto :eof

REM Build de l'image Docker
:build_docker_image
call :log_info "Construction de l'image Docker..."

docker build -t %DOCKER_IMAGE% .
if errorlevel 1 (
    call :log_error "Échec de la construction de l'image Docker"
    exit /b 1
)

call :log_info "Image Docker construite avec succès: %DOCKER_IMAGE%"
goto :eof

REM Déploiement en développement
:deploy_dev
call :log_info "Déploiement en mode développement..."

docker-compose down 2>nul
docker-compose up -d

call :log_info "Application déployée en mode développement"
call :log_info "URL: http://localhost:8080"
call :log_info "H2 Console: http://localhost:8080/h2-console"
goto :eof

REM Déploiement en production
:deploy_prod
call :log_info "Déploiement en mode production..."

if not exist logs mkdir logs
if not exist input mkdir input
if not exist output mkdir output

docker-compose down 2>nul
docker-compose up -d

call :log_info "Attente du démarrage de l'application..."
timeout /t 30 /nobreak >nul

REM Vérifier la santé de l'application
curl -f http://localhost:8080/actuator/health >nul 2>&1
if errorlevel 1 (
    call :log_error "L'application n'est pas accessible"
    exit /b 1
)

call :log_info "Application déployée avec succès en production"
call :log_info "URL: http://localhost:8080"
call :log_info "Monitoring: http://localhost:3000 (Grafana)"
call :log_info "Métriques: http://localhost:9090 (Prometheus)"
goto :eof

REM Tests de santé
:health_check
call :log_info "Vérification de la santé de l'application..."

set max_attempts=30
set attempt=1

:health_check_loop
curl -f http://localhost:8080/actuator/health >nul 2>&1
if not errorlevel 1 (
    call :log_info "Application en bonne santé"
    goto :eof
)

call :log_info "Tentative !attempt!/!max_attempts! - Attente..."
timeout /t 10 /nobreak >nul
set /a attempt+=1

if !attempt! leq !max_attempts! goto health_check_loop

call :log_error "L'application n'est pas accessible après !max_attempts! tentatives"
exit /b 1

REM Nettoyage
:cleanup
call :log_info "Nettoyage des ressources..."

docker image prune -f
docker volume prune -f
goto :eof

REM Fonction principale
:main
call :log_info "Début du déploiement de %APP_NAME% v%VERSION% en mode %ENVIRONMENT%"

call :check_prerequisites
if errorlevel 1 exit /b 1

call :build_application
if errorlevel 1 exit /b 1

if "%ENVIRONMENT%"=="dev" (
    call :build_docker_image
    if errorlevel 1 exit /b 1
    call :deploy_dev
) else if "%ENVIRONMENT%"=="docker" (
    call :build_docker_image
    if errorlevel 1 exit /b 1
    call :deploy_dev
) else if "%ENVIRONMENT%"=="prod" (
    call :build_docker_image
    if errorlevel 1 exit /b 1
    call :deploy_prod
) else (
    call :log_error "Environnement non supporté: %ENVIRONMENT%"
    call :log_info "Environnements supportés: dev, docker, prod"
    exit /b 1
)

call :health_check
if errorlevel 1 exit /b 1

call :cleanup

call :log_info "Déploiement terminé avec succès!"
goto :eof

REM Exécution
call :main %*
