# 🚀 Guide de Déploiement - Foo Bar Quix

## 📋 Vue d'ensemble

Ce guide vous explique comment déployer l'application Foo Bar Quix sur un serveur avec CI/CD automatique via GitHub Actions.

## 🏗️ Architecture de Déploiement

```
GitHub Repository → GitHub Actions → Docker Registry → Serveur → Application
```

## 🔧 Prérequis

### 1. Serveur
- **OS** : Ubuntu 20.04+ ou CentOS 8+
- **RAM** : Minimum 2GB
- **CPU** : 1 vCPU minimum
- **Stockage** : 20GB minimum
- **Docker** : Installé et configuré

### 2. GitHub
- Repository public ou privé
- GitHub Actions activées
- Accès au Container Registry (GHCR)

## 🚀 Déploiement Automatique (CI/CD)

### Étape 1 : Configuration GitHub Actions

Le fichier `.github/workflows/ci-cd.yml` est déjà configuré et fait :

1. **Tests** : Exécute les tests unitaires
2. **Build** : Compile l'application
3. **Docker** : Construit l'image Docker
4. **Push** : Pousse l'image vers GitHub Container Registry
5. **Deploy** : Instructions de déploiement

### Étape 2 : Déclenchement

```bash
# Chaque push sur main déclenche le pipeline
git add .
git commit -m "Update application"
git push origin main
```

### Étape 3 : Vérification

1. Allez sur GitHub → Actions
2. Vérifiez que le pipeline s'exécute
3. L'image est automatiquement poussée vers `ghcr.io/anasbenlemlih/sg_kata`

## 🖥️ Déploiement sur Serveur

### Option A : Déploiement Automatique

```bash
# 1. Configurer l'accès SSH au serveur
ssh-keygen -t rsa -b 4096 -C "deploy@foo-bar-quix"
ssh-copy-id root@YOUR_SERVER_IP

# 2. Lancer le déploiement
./scripts/deploy-server.sh YOUR_SERVER_IP YOUR_GITHUB_TOKEN
```

### Option B : Déploiement Manuel

```bash
# 1. Se connecter au serveur
ssh root@YOUR_SERVER_IP

# 2. Installer Docker (si pas déjà fait)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 3. Télécharger l'image
docker pull ghcr.io/anasbenlemlih/sg_kata:latest

# 4. Lancer l'application
docker run -d -p 8080:8080 --name foo-bar-quix --restart unless-stopped ghcr.io/anasbenlemlih/sg_kata:latest

# 5. Vérifier
curl http://localhost:8080/actuator/health
```

## 🔍 Vérification du Déploiement

### Tests de Base

```bash
# Health Check
curl http://YOUR_SERVER_IP:8080/actuator/health

# Test API
curl http://YOUR_SERVER_IP:8080/api/transform/15
# Réponse attendue: {"result":"FOOBARBAR","input":15}

# Test Batch
curl -X POST http://YOUR_SERVER_IP:8080/api/batch/process
```

### Monitoring

```bash
# Logs de l'application
docker logs foo-bar-quix

# Statut du conteneur
docker ps

# Utilisation des ressources
docker stats foo-bar-quix
```

## 🔄 Mise à Jour

### Automatique (Recommandé)

```bash
# 1. Modifier le code
# 2. Commit et push
git add .
git commit -m "New feature"
git push origin main

# 3. Le pipeline CI/CD se déclenche automatiquement
# 4. Sur le serveur, relancer le déploiement
./scripts/deploy-server.sh YOUR_SERVER_IP
```

### Manuelle

```bash
# Sur le serveur
docker stop foo-bar-quix
docker rm foo-bar-quix
docker pull ghcr.io/anasbenlemlih/sg_kata:latest
docker run -d -p 8080:8080 --name foo-bar-quix --restart unless-stopped ghcr.io/anasbenlemlih/sg_kata:latest
```

## 🛡️ Sécurité

### Variables d'Environnement

```bash
# Créer un fichier .env sur le serveur
cat > /opt/foo-bar-quix/.env << EOF
DATABASE_URL=jdbc:postgresql://localhost:5432/foobarquix
DATABASE_USERNAME=foobarquix
DATABASE_PASSWORD=your_secure_password
SERVER_PORT=8080
EOF

# Lancer avec les variables
docker run -d -p 8080:8080 --env-file /opt/foo-bar-quix/.env --name foo-bar-quix ghcr.io/anasbenlemlih/sg_kata:latest
```

### Firewall

```bash
# Ouvrir le port 8080
ufw allow 8080/tcp
ufw reload
```

## 🔧 Troubleshooting

### Problèmes Courants

1. **Port déjà utilisé**
   ```bash
   # Vérifier les ports utilisés
   netstat -tulpn | grep :8080
   
   # Arrêter le processus
   docker stop foo-bar-quix
   ```

2. **Image non trouvée**
   ```bash
   # Vérifier l'authentification
   echo $GITHUB_TOKEN | docker login ghcr.io -u anasbenlemlih --password-stdin
   ```

3. **Application ne démarre pas**
   ```bash
   # Vérifier les logs
   docker logs foo-bar-quix
   
   # Vérifier les ressources
   docker stats foo-bar-quix
   ```

### Logs et Debug

```bash
# Logs en temps réel
docker logs -f foo-bar-quix

# Logs avec timestamps
docker logs -t foo-bar-quix

# Accès au conteneur
docker exec -it foo-bar-quix /bin/bash
```

## 📊 Monitoring Avancé

### Avec Docker Compose (Optionnel)

```bash
# Sur le serveur, créer docker-compose.prod.yml
cat > docker-compose.prod.yml << EOF
version: '3.8'
services:
  foo-bar-quix:
    image: ghcr.io/anasbenlemlih/sg_kata:latest
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

# Lancer
docker-compose -f docker-compose.prod.yml up -d
```

## 🎯 Résumé des URLs

- **Application** : http://YOUR_SERVER_IP:8080
- **API Test** : http://YOUR_SERVER_IP:8080/api/transform/15
- **Health Check** : http://YOUR_SERVER_IP:8080/actuator/health
- **GitHub Actions** : https://github.com/AnasBenlemlih/SG_KATA/actions
- **Container Registry** : https://github.com/AnasBenlemlih/SG_KATA/pkgs/container/sg_kata

## 🆘 Support

En cas de problème :
1. Vérifiez les logs : `docker logs foo-bar-quix`
2. Vérifiez le statut : `docker ps`
3. Vérifiez les ressources : `docker stats`
4. Consultez GitHub Actions pour les erreurs de build
