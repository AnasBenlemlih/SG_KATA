# 🚀 Guide de Déploiement Simple - Foo Bar Quix

## 🎯 Solutions Gratuites et Simples

### **Option 1 : Railway (Recommandé)**

1. **Allez sur** : https://railway.app/
2. **Connectez-vous** avec GitHub
3. **Cliquez** "New Project" → "Deploy from GitHub repo"
4. **Sélectionnez** votre repository `SG_KATA`
5. **Railway détecte automatiquement** Java et déploie
6. **C'est tout !** Vous obtenez une URL publique

### **Option 2 : Render (Alternative)**

1. **Allez sur** : https://render.com/
2. **Créez un compte** gratuit
3. **Connectez** votre GitHub
4. **Créez** un "Web Service"
5. **Sélectionnez** votre repository `SG_KATA`
6. **Render détecte** automatiquement Java

### **Option 3 : Votre PC + ngrok (Local Public)**

1. **Lancez votre app** (elle fonctionne déjà sur le port 8081)
2. **Téléchargez ngrok** : https://ngrok.com/download
3. **Lancez ngrok** : `ngrok http 8081`
4. **Utilisez l'URL** fournie par ngrok

### **Option 4 : Serveur VPS Gratuit**

#### **Oracle Cloud (Toujours Gratuit)**
1. **Allez sur** : https://cloud.oracle.com/
2. **Créez un compte** gratuit
3. **Créez une instance** "Always Free"
4. **Suivez le guide** ci-dessous

#### **Google Cloud (300$ de crédit gratuit)**
1. **Allez sur** : https://cloud.google.com/
2. **Créez un compte** avec crédit gratuit
3. **Créez une VM**
4. **Suivez le guide** ci-dessous

## 🖥️ Déploiement sur Serveur VPS

### **Étape 1 : Connexion au serveur**

```bash
# Se connecter au serveur
ssh root@VOTRE_IP_SERVEUR
```

### **Étape 2 : Installation de Docker**

```bash
# Mettre à jour le système
apt update && apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Démarrer Docker
systemctl start docker
systemctl enable docker

# Vérifier l'installation
docker --version
```

### **Étape 3 : Déploiement de l'application**

```bash
# Cloner le repository
git clone https://github.com/AnasBenlemlih/SG_KATA.git
cd SG_KATA

# Construire l'image Docker
docker build -f Dockerfile.working -t foo-bar-quix .

# Lancer l'application
docker run -d -p 8080:8080 --name foo-bar-quix --restart unless-stopped foo-bar-quix

# Vérifier que ça fonctionne
curl http://localhost:8080/actuator/health
```

### **Étape 4 : Configuration du firewall**

```bash
# Ouvrir le port 8080
ufw allow 8080/tcp
ufw reload
```

## 🔍 Vérification du Déploiement

### **Tests de Base**

```bash
# Health Check
curl http://VOTRE_IP_SERVEUR:8080/actuator/health

# Test API
curl http://VOTRE_IP_SERVEUR:8080/api/transform/15
# Réponse attendue: {"result":"FOOBARBAR","input":15}

# Test Batch
curl -X POST http://VOTRE_IP_SERVEUR:8080/api/batch/process
```

### **Monitoring**

```bash
# Logs de l'application
docker logs foo-bar-quix

# Statut du conteneur
docker ps

# Utilisation des ressources
docker stats foo-bar-quix
```

## 🔄 Mise à Jour

### **Automatique (Recommandé)**

```bash
# 1. Modifier le code
# 2. Commit et push
git add .
git commit -m "New feature"
git push origin main

# 3. Sur le serveur, mettre à jour
cd SG_KATA
git pull origin main
docker stop foo-bar-quix
docker rm foo-bar-quix
docker build -f Dockerfile.working -t foo-bar-quix .
docker run -d -p 8080:8080 --name foo-bar-quix --restart unless-stopped foo-bar-quix
```

## 🛡️ Sécurité

### **Variables d'Environnement**

```bash
# Créer un fichier .env sur le serveur
cat > /opt/foo-bar-quix/.env << EOF
DATABASE_URL=jdbc:postgresql://localhost:5432/foobarquix
DATABASE_USERNAME=foobarquix
DATABASE_PASSWORD=your_secure_password
SERVER_PORT=8080
EOF

# Lancer avec les variables
docker run -d -p 8080:8080 --env-file /opt/foo-bar-quix/.env --name foo-bar-quix foo-bar-quix
```

## 🔧 Troubleshooting

### **Problèmes Courants**

1. **Port déjà utilisé**
   ```bash
   # Vérifier les ports utilisés
   netstat -tulpn | grep :8080
   
   # Arrêter le processus
   docker stop foo-bar-quix
   ```

2. **Application ne démarre pas**
   ```bash
   # Vérifier les logs
   docker logs foo-bar-quix
   
   # Vérifier les ressources
   docker stats foo-bar-quix
   ```

3. **Problème de mémoire**
   ```bash
   # Vérifier la mémoire disponible
   free -h
   
   # Redémarrer avec moins de mémoire
   docker run -d -p 8080:8080 -e JAVA_OPTS="-Xmx512m" --name foo-bar-quix foo-bar-quix
   ```

## 🎯 Résumé des URLs

- **Application** : http://VOTRE_IP_SERVEUR:8080
- **API Test** : http://VOTRE_IP_SERVEUR:8080/api/transform/15
- **Health Check** : http://VOTRE_IP_SERVEUR:8080/actuator/health
- **GitHub Repository** : https://github.com/AnasBenlemlih/SG_KATA
- **GitHub Actions** : https://github.com/AnasBenlemlih/SG_KATA/actions

## 🆘 Support

En cas de problème :
1. Vérifiez les logs : `docker logs foo-bar-quix`
2. Vérifiez le statut : `docker ps`
3. Vérifiez les ressources : `docker stats`
4. Consultez GitHub Actions pour les erreurs de build

## 🎉 Félicitations !

Votre application Foo Bar Quix est maintenant déployée et accessible publiquement !
