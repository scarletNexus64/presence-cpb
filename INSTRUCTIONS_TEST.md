# Instructions de test pour le système de scan de présence

## 🚀 Configuration et test du backend Laravel

### 1. Démarrer le serveur Laravel
```bash
cd "/Users/macbookpro/Desktop/Developments/Personnals/School College App/college-management-app/back"
php artisan serve --host 0.0.0.0
```

Le serveur sera accessible à `http://admin1.cpb-douala.com`

### 2. Tester les endpoints avec curl

#### Test de base (sans authentification)
```bash
curl -X GET http://admin1.cpb-douala.com/api/test
```

#### Test endpoint debug sans auth
```bash
curl -X POST http://admin1.cpb-douala.com/api/test/scan-qr-no-auth \
  -H "Content-Type: application/json" \
  -d '{
    "staff_qr_code": "TEST_QR",
    "supervisor_id": 1,
    "test_data": "Hello from curl"
  }'
```

#### Test avec JWT (nécessite un token valide)
```bash
curl -X POST http://admin1.cpb-douala.com/api/test/scan-qr-with-debug-auth \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "test_data": "JWT Test"
  }'
```

### 3. Obtenir un token JWT

#### Créer un utilisateur de test
```bash
php artisan tinker
```

Dans tinker :
```php
$user = new App\Models\User();
$user->name = 'Test Bibliothecaire';
$user->username = 'biblio_test'; 
$user->email = 'biblio@test.com';
$user->password = Hash::make('password123');
$user->role = 'bibliothecaire';
$user->is_active = true;
$user->save();
```

#### Se connecter pour obtenir un token
```bash
curl -X POST http://admin1.cpb-douala.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "biblio_test",
    "password": "password123"
  }'
```

## 📱 Configuration et test de l'application Flutter

### 1. Installer les dépendances
```bash
cd /Users/macbookpro/Desktop/Developments/Personnals/Scan/presence_cpb
flutter pub get
```

### 2. Vérifier la configuration
- Le fichier `.env` a été configuré avec votre IP locale : `192.168.1.231:8000`
- Le debug est activé pour voir tous les logs

### 3. Lancer l'application
```bash
flutter run
```

### 4. Test du flux complet

1. **Splash Screen** : L'app vérifie la connexion et l'authentification
2. **Écran de connexion** : Si pas authentifié, utilise les credentials :
   - Nom d'utilisateur: `biblio_test`
   - Mot de passe: `password123`
3. **Test de connexion** : Utilise le bouton "Tester la connexion" pour vérifier la connectivité
4. **Scan QR** : Une fois connecté, test le scan avec des QR codes

## 🔧 Debug et logs

### Backend Laravel
Les logs sont dans `storage/logs/laravel.log` :
```bash
tail -f "/Users/macbookpro/Desktop/Developments/Personnals/School College App/college-management-app/back/storage/logs/laravel.log"
```

### Application Flutter
Tous les logs HTTP apparaissent dans la console Flutter avec des emojis :
- 🔗 REQUEST
- ✅ RESPONSE  
- ❌ ERROR
- 🔑 JWT Token

## ⚠️ Résolution de problèmes

### Erreur 401 - Non authentifié
1. Vérifiez que le token JWT est bien sauvegardé
2. Testez l'endpoint debug : `/api/test/scan-qr-with-debug-auth`
3. Regardez les logs Laravel pour voir les détails de l'erreur

### Erreur de connexion
1. Vérifiez que Laravel serve est bien démarré
2. Testez avec l'endpoint sans auth : `/api/test/scan-qr-no-auth`
3. Vérifiez l'IP dans le fichier `.env`

### Logs détaillés
Le middleware `DebugJWTAuth` logge tous les détails de l'authentification.

## 🧪 Tests unitaires

Lancer les tests Laravel :
```bash
cd "/Users/macbookpro/Desktop/Developments/Personnals/School College App/college-management-app/back"
php artisan test --filter StaffAttendanceTest
```

## 📋 Checklist de validation

- [ ] Serveur Laravel accessible
- [ ] Endpoint test sans auth fonctionne
- [ ] Authentification JWT fonctionne
- [ ] Application Flutter se lance
- [ ] Splash screen fonctionne
- [ ] Connexion utilisateur réussie
- [ ] Scan QR avec logs détaillés
- [ ] Tests unitaires passent

## 🔍 Endpoints disponibles

### Sans authentification
- `GET /api/test` - Test simple
- `POST /api/test/scan-qr-no-auth` - Test scan sans auth

### Avec authentification
- `POST /api/auth/login` - Connexion
- `POST /api/logout` - Déconnexion
- `POST /api/test/scan-qr-with-debug-auth` - Test JWT
- `POST /api/test/staff-attendance-debug` - Test staff attendance avec debug
- `POST /api/staff-attendance/scan-qr` - Endpoint principal

Tous les endpoints sont maintenant loggés en détail ! 🎉