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

### JAR exécutable

```bash
# Build
mvn clean package

# Déploiement
java -jar target/foo-bar-quix-1.0.0.jar
```

## Monitoring

- **H2 Console** : http://localhost:8080/h2-console