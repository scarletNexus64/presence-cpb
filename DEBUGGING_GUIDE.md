# 🐛 Guide de Débogage - Système de Présences CPB

## 📊 Système de Logs avec Emojis

Le système utilise maintenant des logs détaillés avec emojis pour tracer tout le flux de données depuis l'API backend.

### 🎯 Points de Logs Principaux

#### 1. 🚀 SectionsScreen - Récupération des Sections/Cycles
**Fichier :** `lib/screens/student/sections_screen.dart`

```dart
🚀 ========== DÉBUT RÉCUPÉRATION DES SECTIONS ==========
📍 Endpoint ciblé: /api/sections
🔄 Envoi de la requête API...
```

**Logs de succès :**
```dart
📊 ========== ANALYSE DE LA RÉPONSE ==========
✅ Réponse reçue: SUCCÈS
📋 ========== DONNÉES REÇUES ==========
📊 Nombre de sections trouvées: X
🎯 Section X/Y:
   🆔 ID: 1
   📚 Nom: Maternelle
   📝 Description: Petite section, Moyenne section...
   🎨 Couleur: #FF6B6B
   🎭 Icône: child_care
   ✅ Active: true
```

**Logs d'échec :**
```dart
⚠️ ========== ÉCHEC DE L'API ==========
❌ Message d'erreur: [message]
🔄 Basculement vers les données mock...
```

#### 2. 🌐 StudentApiService - Requêtes API Détaillées
**Fichier :** `lib/services/student_api_service.dart`

**Pour les Sections :**
```dart
🌐 ========== REQUÊTE API SECTIONS ==========
📡 URL complète: http://192.168.1.231:8000/api/sections
🔑 Headers: {Content-Type: application/json, ...}
⏰ Timestamp: 2025-09-08T19:45:00.000Z
🚀 Envoi de la requête HTTP GET...

📨 ========== RÉPONSE DU SERVEUR ==========
🎯 Status Code: 200
📏 Taille de la réponse: 1250 caractères
🏷️ Content-Type: application/json
```

**Pour les Niveaux :**
```dart
🌐 ========== REQUÊTE API NIVEAUX ==========
📡 URL complète: http://192.168.1.231:8000/api/mobile/sections/1/levels
🆔 Section ID: 1
🔑 Headers: {Content-Type: application/json, ...}
⏰ Timestamp: 2025-09-08T19:45:05.000Z
🚀 Envoi de la requête HTTP GET pour les niveaux...
```

#### 3. 🎯 Navigation Between Screens
```dart
🎯 ========== NAVIGATION VERS LES NIVEAUX ==========
📚 Section sélectionnée: Maternelle
🆔 ID de la section: 1
🔄 Redirection vers LevelsScreen...
📍 Endpoint suivant: /api/mobile/sections/1/levels
```

### 🔍 Types de Logs par Emoji

| Emoji | Signification | Utilisation |
|-------|---------------|-------------|
| 🚀 | Début d'opération | Initialisation de processus |
| 📍 | Endpoint/URL | Indication de l'URL ciblée |
| 🔄 | Opération en cours | Actions en cours d'exécution |
| ✅ | Succès | Opérations réussies |
| ❌ | Erreur | Erreurs et échecs |
| ⚠️ | Avertissement | Situations dégradées |
| 📊 | Données/Stats | Analyse de données |
| 🎯 | Spécifique/Ciblé | Actions précises |
| 🌐 | Réseau/API | Requêtes réseau |
| 📨 | Réponse | Réponses serveur |
| 🔑 | Authentication | Headers et tokens |
| 💥 | Exception | Exceptions critiques |
| 🎭 | Mode dégradé | Données mock |
| 📋 | Métadonnées | Informations structure |
| 🏫 | Sections | Éléments éducatifs |
| 🎓 | Niveaux | Niveaux d'enseignement |

### 🛠️ Comment Utiliser les Logs

#### 1. **Activer les Logs de Debug**
```dart
import 'dart:developer' as developer;

// Dans votre méthode
developer.log('🚀 Message de debug', name: 'CPB_DEBUG');
```

#### 2. **Filtrer les Logs dans la Console**
- **Android Studio/IntelliJ :** Filtrer par `🚀` ou `CPB`
- **VS Code :** Utiliser l'extension Flutter et filtrer la console
- **Terminal :** `flutter run | grep "🚀"`

#### 3. **Niveaux de Debug**
```dart
// Debug niveau INFO
print('ℹ️ Information générale');

// Debug niveau WARNING  
print('⚠️ Avertissement important');

// Debug niveau ERROR
print('🔴 Erreur critique');

// Debug niveau SUCCESS
print('✅ Opération réussie');
```

### 🔧 Debugging Workflow

#### Problème : Les sections ne se chargent pas
1. Vérifier les logs `🚀 ========== DÉBUT RÉCUPÉRATION`
2. Chercher `🌐 ========== REQUÊTE API SECTIONS`
3. Analyser le status code `🎯 Status Code:`
4. Vérifier la structure des données `📊 ========== ANALYSE`

#### Problème : Erreur de réseau
1. Vérifier l'URL `📡 URL complète:`
2. Contrôler les headers `🔑 Headers:`
3. Analyser l'exception `💥 ========== EXCEPTION`

#### Problème : Données malformées
1. Vérifier `📊 ========== ANALYSE DES DONNÉES`
2. Contrôler `🔑 Clés disponibles:`
3. Analyser la structure retournée

### 🎯 Endpoints API Tracés

1. **Sections :** `GET /api/sections`
2. **Niveaux :** `GET /api/mobile/sections/{sectionId}/levels`
3. **Classes :** `GET /api/mobile/levels/{levelId}/classes`
4. **Séries :** `GET /api/mobile/classes/{classId}/series`
5. **Étudiants :** `GET /api/mobile/students/series/{seriesId}`

### 🚨 Cas d'Erreurs Courants

#### 1. Erreur 401 - Non autorisé
```dart
❌ ========== ERREUR HTTP ==========
🔴 Status Code: 401
📝 Corps de la réponse: {"message":"Unauthorized"}
```
**Solution :** Vérifier le token d'authentification

#### 2. Erreur 404 - Endpoint introuvable
```dart
❌ ========== ERREUR HTTP ==========
🔴 Status Code: 404
📝 Corps de la réponse: {"message":"Not Found"}
```
**Solution :** Vérifier l'URL de l'endpoint

#### 3. Erreur réseau
```dart
💥 ========== EXCEPTION ATTRAPÉE ==========
🔴 Type: SocketException
📝 Message: Failed host lookup: '192.168.1.231'
```
**Solution :** Vérifier la connectivité réseau et l'URL de base

### 📱 Configuration pour les Logs

#### .env Configuration
```
API_BASE_URL=http://192.168.1.231:8000
DEBUG_MODE=true
ENABLE_LOGGING=true
```

#### Désactiver les Logs en Production
```dart
static const bool _debugMode = !kReleaseMode;

void debugLog(String message) {
  if (_debugMode) {
    print(message);
  }
}
```

---

## 🎉 Utilisation

Avec ce système de logs, vous pouvez maintenant :

1. **Tracer complètement** le flux de données depuis l'API
2. **Identifier rapidement** les points de défaillance
3. **Analyser les réponses** du serveur en détail
4. **Déboguer efficacement** les problèmes de réseau
5. **Valider la structure** des données reçues

Les logs sont désormais **visuellement distinctifs** grâce aux emojis et offrent une **traçabilité complète** du système de présences CPB.