# Foo Bar Quix Kata

Application Spring Boot implémentant l'algorithme de transformation FOO BAR QUIX avec Spring Batch.

## Description

Cette application transforme des nombres (0-100) en chaînes de caractères selon les règles suivantes :

- **FOO** : Si le nombre est divisible par 3 ou contient le chiffre 3
- **BAR** : Si le nombre est divisible par 5 ou contient le chiffre 5  
- **QUIX** : Si le nombre contient le chiffre 7

### Règles de priorité

1. La règle "divisible par" est plus prioritaire que "contient"
2. L'analyse se fait de gauche à droite
3. Si aucune règle n'est vérifiée, retourner le nombre original

### Exemples

| Input | Output |
|-------|--------|
| 1     | "1"    |
| 3     | "FOOFOO" |
| 5     | "BARBAR" |
| 7     | "QUIX" |
| 9     | "FOO" |
| 15    | "FOOBARBAR" |
| 33    | "FOOFOOFOO" |
| 51    | "FOOBAR" |
| 53    | "BARFOO" |

## Technologies

- Java 17
- Spring Boot 3.2.0
- Spring Batch
- Spring Web
- Spring Data JPA
- H2 Database
- Maven

## Prérequis

- Java 17 ou supérieur
- Maven 3.6+

## Installation et Lancement

### 1. Cloner le projet

```bash
git clone <repository-url>
cd foo-bar-quix
```

### 2. Build et lancement avec Maven

```bash
# Build du projet
mvn clean package

# Lancement de l'application
java -jar target/foo-bar-quix-1.0.0.jar
```

## API REST

L'application expose une API REST sur le port 8080.

### Endpoints

#### 1. Transformation d'un nombre

```http
GET /api/transform/{number}
```

**Exemple :**
```bash
curl http://localhost:8080/api/transform/15
```

**Réponse :**
```json
{
  "input": 15,
  "result": "FOOBARBAR"
}
```

#### 2. Lancement du traitement par lot

```http
POST /api/batch/process
```

## Traitement par lot (Spring Batch)

### Configuration

Le traitement par lot lit un fichier `input/numbers.txt` et génère un fichier `output/result.txt`.

### Format du fichier d'entrée

```
1
3
5
7
9
51
53
33
33
15
```

### Format du fichier de sortie

```
1 "1"
3 "FOOFOO"
5 "BARBAR"
7 "QUIX"
9 "FOO"
51 "FOOBAR"
53 "BARFOO"
33 "FOOFOOFOO"
33 "FOOFOOFOO"
15 "FOOBARBAR"
```

### Lancement du batch

1. **Via API REST :**
```bash
curl -X POST http://localhost:8080/api/batch/process
```

2. **Via fichier d'entrée :**
   - Créer le dossier `input/`
   - Placer le fichier `numbers.txt` dans `input/`
   - Lancer l'API batch
   - Récupérer le résultat dans `output/result.txt`

## Tests

### Exécution des tests

```bash
# Tests unitaires et d'intégration
mvn test
```

### Types de tests

- **Tests unitaires** : Service de transformation
- **Tests d'intégration** : Controllers REST
- **Tests de batch** : Traitement par lot complet

## Structure du projet

```
src/
├── main/
│   ├── java/com/kata/foobarquix/
│   │   ├── FooBarQuixApplication.java
│   │   ├── controller/
│   │   │   ├── NumberTransformationController.java
│   │   │   └── BatchController.java
│   │   ├── service/
│   │   │   └── NumberTransformationService.java
│   │   ├── batch/
│   │   │   ├── NumberItemReader.java
│   │   │   ├── NumberItemProcessor.java
│   │   │   └── NumberItemWriter.java
│   │   ├── config/
│   │   │   └── BatchConfig.java
│   │   └── model/
│   │       └── NumberRecord.java
│   └── resources/
│       └── application.yml
└── test/
    └── java/com/kata/foobarquix/
        ├── FooBarQuixApplicationTest.java
        ├── service/
        │   └── NumberTransformationServiceTest.java
        └── controller/
            └── NumberTransformationControllerTest.java
```

## Exemples d'utilisation

### 1. Test de l'API

```bash
# Test simple
curl http://localhost:8080/api/transform/15

# Test avec nombre invalide
curl http://localhost:8080/api/transform/101
```

### 2. Traitement par lot

```bash
# Créer le fichier d'entrée
mkdir -p input
echo -e "1\n3\n5\n7\n9\n15\n33\n51\n53" > input/numbers.txt

# Lancer le traitement
curl -X POST http://localhost:8080/api/batch/process

# Vérifier le résultat
cat output/result.txt
```

## Déploiement

### 🚀 Solutions de Packaging et Déploiement

L'application propose plusieurs options de déploiement adaptées à différents environnements :

#### 1. Déploiement JAR Standard

```bash
# Build avec profil par défaut (dev)
mvn clean package

# Déploiement
java -jar target/foo-bar-quix-1.0.0.jar
```

#### 2. Déploiement avec Docker

##### Option A : Docker Compose (Recommandé)

```bash
# Déploiement complet avec monitoring
docker-compose up -d

# Vérification des services
docker-compose ps
```

##### Option B : Image Docker seule

```bash
# Build de l'image
docker build -t foo-bar-quix:1.0.0 .

# Exécution
docker run -p 8080:8080 -v $(pwd)/input:/app/input -v $(pwd)/output:/app/output foo-bar-quix:1.0.0
```

#### 3. Déploiement Automatisé

##### Script Linux/Mac

```bash
# Déploiement en développement
./scripts/deploy.sh dev

# Déploiement en production
./scripts/deploy.sh prod 1.0.0
```

##### Script Windows

```cmd
REM Déploiement en développement
scripts\deploy.bat dev

REM Déploiement en production
scripts\deploy.bat prod 1.0.0
```

### 🔧 Profils Maven

L'application supporte plusieurs profils pour différents environnements :

```bash
# Développement (par défaut)
mvn clean package -Pdev

# Docker
mvn clean package -Pdocker

# Production
mvn clean package -Pprod

# Build avec image Docker
mvn clean package -Pdocker-build
```

### 🌐 Environnements

#### Développement
- **Base de données** : H2 en mémoire
- **Port** : 8080
- **Monitoring** : Actuator endpoints

#### Docker
- **Base de données** : PostgreSQL
- **Port** : 8080
- **Monitoring** : Prometheus + Grafana
- **Volumes** : `./input`, `./output`, `./logs`

#### Production
- **Base de données** : PostgreSQL externe
- **Configuration** : Variables d'environnement
- **Monitoring** : Prometheus + Grafana
- **Logs** : Fichiers persistants

### 📊 Monitoring et Observabilité

#### Endpoints de Monitoring

- **Health Check** : http://localhost:8080/actuator/health
- **Métriques** : http://localhost:8080/actuator/metrics
- **Prometheus** : http://localhost:8080/actuator/prometheus

#### Dashboards Grafana

- **URL** : http://localhost:3000
- **Login** : admin / admin
- **Dashboard** : Foo Bar Quix - Monitoring Dashboard

#### Métriques Prometheus

- **URL** : http://localhost:9090
- **Targets** : Application, PostgreSQL, Node Exporter

### 🔐 Variables d'Environnement (Production)

```bash
# Base de données
DATABASE_URL=jdbc:postgresql://localhost:5432/foobarquix
DATABASE_USERNAME=foobarquix
DATABASE_PASSWORD=your_password

# Serveur
SERVER_PORT=8080
CONTEXT_PATH=/

# Logs
LOG_FILE_PATH=/var/log/foo-bar-quix/application.log

# Batch
BATCH_INPUT_FILE=/app/input/numbers.txt
BATCH_OUTPUT_FILE=/app/output/result.txt
```

### 🐳 Architecture Docker

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   PostgreSQL    │    │   Prometheus    │
│   (Port 8080)   │◄──►│   (Port 5432)   │    │   (Port 9090)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         │                                              ▼
         │                                    ┌─────────────────┐
         └────────────────────────────────────►│     Grafana     │
                                              │   (Port 3000)   │
                                              └─────────────────┘
```

### 📁 Structure de Déploiement

```
project/
├── Dockerfile                 # Image Docker de l'application
├── docker-compose.yml         # Orchestration des services
├── scripts/
│   ├── deploy.sh             # Script de déploiement Linux/Mac
│   └── deploy.bat            # Script de déploiement Windows
├── monitoring/
│   ├── prometheus.yml        # Configuration Prometheus
│   ├── init-db.sql          # Script d'initialisation DB
│   └── grafana/
│       ├── datasources/      # Sources de données Grafana
│       └── dashboards/       # Dashboards de monitoring
├── input/                    # Fichiers d'entrée (monté en volume)
├── output/                   # Fichiers de sortie (monté en volume)
└── logs/                     # Logs de l'application (monté en volume)
```

### 🚀 Déploiement en Ligne de Commande

#### Développement Rapide

```bash
# 1. Cloner le projet
git clone <repository-url>
cd foo-bar-quix

# 2. Déploiement avec Docker Compose
docker-compose up -d

# 3. Vérifier le déploiement
curl http://localhost:8080/actuator/health
```

#### Production

```bash
# 1. Configuration des variables d'environnement
export DATABASE_URL=jdbc:postgresql://your-db:5432/foobarquix
export DATABASE_USERNAME=your_user
export DATABASE_PASSWORD=your_password

# 2. Déploiement automatisé
./scripts/deploy.sh prod 1.0.0

# 3. Vérification
curl http://localhost:8080/actuator/health
```

### 🔍 Troubleshooting

#### Vérification des Services

```bash
# Statut des conteneurs
docker-compose ps

# Logs de l'application
docker-compose logs foo-bar-quix

# Logs de la base de données
docker-compose logs postgres

# Logs de Prometheus
docker-compose logs prometheus
```

#### Tests de Connectivité

```bash
# Test de l'API
curl http://localhost:8080/api/transform/15

# Test du batch
curl -X POST http://localhost:8080/api/batch/process

# Test de la base de données
docker-compose exec postgres psql -U foobarquix -d foobarquix -c "SELECT 1;"
```

## Monitoring

- **H2 Console** : http://localhost:8080/h2-console (dev uniquement)
- **Grafana Dashboard** : http://localhost:3000 (admin/admin)
- **Prometheus** : http://localhost:9090
- **Health Check** : http://localhost:8080/actuator/health