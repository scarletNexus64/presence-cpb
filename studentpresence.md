# 📋 Documentation d'Intégration API Présences - CPB

## 🏗️ Architecture du Système

### Structure Hiérarchique Backend
```
Sections (Maternelle, Primaire, Secondaire)
  └── Levels (Cycles/Niveaux)
      └── SchoolClasses (Classes)
          └── ClassSeries (Séries/Variantes: A, B, C...)
              └── Students (Eleves)
```

### Modèles de Données
- **Section** : Division principale (Maternelle, Primaire, etc.)
- **Level** : Niveau/Cycle dans une section (CP, CE1, 6ème, etc.)
- **SchoolClass** : Classe dans un niveau
- **ClassSeries** : Série/Variante d'une classe (6ème A, 6ème B)
- **Student** : Étudiant inscrit dans une série

---

## ❌ API MANQUANTES À IMPLÉMENTER

### 1. Routes de Navigation Hiérarchique Mobile

#### 1.1 Récupérer les niveaux d'une section
```http
GET /api/mobile/sections/{sectionId}/levels
```
**Réponse attendue :**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "CP",
      "section_id": 2,
      "display_order": 1
    }
  ]
}
```

#### 1.2 Récupérer les classes d'un niveau
```http
GET /api/mobile/levels/{levelId}/classes
```
**Réponse attendue :**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "6ème",
      "level_id": 1
    }
  ]
}
```

#### 1.3 Récupérer les séries d'une classe
```http
GET /api/mobile/classes/{classId}/series
```
**Réponse attendue :**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "A",
      "class_id": 1,
      "full_name": "6ème A"
    }
  ]
}
```

#### 1.4 Récupérer les Eleves d'une série
```http
GET /api/mobile/students/series/{seriesId}
```
**Réponse attendue :**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "student_number": "2024-001",
      "first_name": "Jean",
      "last_name": "Dupont",
      "order": 1,
      "attendance_status": null
    }
  ]
}
```

---

### 2. Endpoint de Soumission des Présences en Masse

#### 2.1 Soumettre les présences d'une série complète
```http
POST /api/attendance/students/submit
```

**Corps de la requête :**
```json
{
  "series_id": 1,
  "event_type": "entry",
  "attendance_date": "2025-01-10",
  "students": [
    {
      "student_id": 123,
      "is_present": true,
      "student_number": "2024-001"
    },
    {
      "student_id": 124,
      "is_present": false,
      "student_number": "2024-002"
    }
  ],
  "notes": "Appel d'entrée via application mobile"
}
```

**Réponse attendue :**
```json
{
  "success": true,
  "message": "Présences enregistrées avec succès",
  "data": {
    "series_name": "6ème A",
    "event_type": "entry",
    "attendance_date": "10/01/2025",
    "total_students": 25,
    "present_count": 23,
    "absent_count": 2,
    "success_count": 25,
    "error_count": 0
  }
}
```

---

### 3. Statistiques de Présences Améliorées

#### 3.1 Obtenir les statistiques avec filtres
```http
GET /api/attendance/students/stats
```

**Paramètres de requête :**
- `date` : Date des présences (format: YYYY-MM-DD)
- `section_id` : (optionnel) Filtrer par section
- `level_id` : (optionnel) Filtrer par niveau
- `class_id` : (optionnel) Filtrer par classe
- `series_id` : (optionnel) Filtrer par série

**Réponse attendue :**
```json
{
  "success": true,
  "data": {
    "date": "2025-01-10",
    "total_students": 250,
    "present": 230,
    "absent": 20,
    "exited": 15,
    "currently_present": 215,
    "attendance_rate": 92.0
  }
}
```

---

## 🔄 MODIFICATIONS BACKEND NÉCESSAIRES

### 1. Créer un nouveau contrôleur
**Fichier :** `app/Http/Controllers/MobileAttendanceController.php`

```php
<?php
namespace App\Http\Controllers;

class MobileAttendanceController extends Controller
{
    // Méthodes pour les routes de navigation
    public function getLevelsBySection($sectionId) { }
    public function getClassesByLevel($levelId) { }
    public function getSeriesByClass($classId) { }
    public function getStudentsBySeries($seriesId) { }
    
    // Méthode pour soumettre les présences
    public function submitBulkAttendance(Request $request) { }
    
    // Méthode pour les statistiques
    public function getAttendanceStats(Request $request) { }
}
```

### 2. Ajouter les routes dans `routes/api.php`
```php
Route::middleware('auth:api')->prefix('mobile')->group(function () {
    // Navigation
    Route::get('/sections/{sectionId}/levels', [MobileAttendanceController::class, 'getLevelsBySection']);
    Route::get('/levels/{levelId}/classes', [MobileAttendanceController::class, 'getClassesByLevel']);
    Route::get('/classes/{classId}/series', [MobileAttendanceController::class, 'getSeriesByClass']);
    Route::get('/students/series/{seriesId}', [MobileAttendanceController::class, 'getStudentsBySeries']);
});

Route::middleware('auth:api')->prefix('attendance/students')->group(function () {
    // Soumission et statistiques
    Route::post('/submit', [MobileAttendanceController::class, 'submitBulkAttendance']);
    Route::get('/stats', [MobileAttendanceController::class, 'getAttendanceStats']);
});
```

### 3. Middleware et Permissions
```php
// Ajouter les rôles autorisés
->middleware(['role:admin,teacher,surveillant_general,bibliothecaire']);
```

---

## 🔧 CORRECTIONS FRONTEND NÉCESSAIRES

### 1. Adapter les appels API dans `student_api_service.dart`

#### Remplacer les URLs actuelles :
```dart
// AVANT
Uri.parse('$baseUrl/api/sections/$sectionId/levels')

// APRÈS
Uri.parse('$baseUrl/api/mobile/sections/$sectionId/levels')
```

#### Corriger le mapping des champs :
```dart
// Dans getStudentsBySeries
'first_name': student.first_name ?: student.name,
'last_name': student.last_name ?: student.subname,
```

### 2. Gestion de l'authentification
Vérifier que le token JWT est bien envoyé dans les headers :
```dart
headers['Authorization'] = 'Bearer $_authToken';
```

---

## 📊 TABLEAU DE SUIVI D'IMPLÉMENTATION

| Endpoint | Priorité | Status | Responsable | Notes |
|----------|----------|--------|-------------|-------|
| GET /mobile/sections/{id}/levels | 🔴 Urgent | ❌ À faire | Backend | Bloquant pour navigation |
| GET /mobile/levels/{id}/classes | 🔴 Urgent | ❌ À faire | Backend | Bloquant pour navigation |
| GET /mobile/classes/{id}/series | 🔴 Urgent | ❌ À faire | Backend | Bloquant pour navigation |
| GET /mobile/students/series/{id} | 🔴 Urgent | ❌ À faire | Backend | Bloquant pour appel |
| POST /attendance/students/submit | 🔴 Urgent | ❌ À faire | Backend | Bloquant pour soumission |
| GET /attendance/students/stats | 🟡 Important | ❌ À faire | Backend | Pour dashboard |
| Adapter URLs Frontend | 🔴 Urgent | ❌ À faire | Frontend | Après création API |
| Tests d'intégration | 🟡 Important | ❌ À faire | QA | Après implémentation |

---

## 🚀 ÉTAPES D'IMPLÉMENTATION RECOMMANDÉES

### Phase 1 : Backend (2h)
1. ✅ Créer `MobileAttendanceController.php`
2. ✅ Implémenter les 4 méthodes de navigation
3. ✅ Implémenter `submitBulkAttendance()`
4. ✅ Ajouter les routes dans `api.php`
5. ✅ Tester avec Postman

### Phase 2 : Frontend (1h)
1. ✅ Mettre à jour les URLs dans `student_api_service.dart`
2. ✅ Corriger le mapping des champs
3. ✅ Vérifier l'authentification JWT
4. ✅ Tester l'intégration complète

### Phase 3 : Tests & Validation (1h)
1. ✅ Tests unitaires backend
2. ✅ Tests d'intégration
3. ✅ Tests de performance
4. ✅ Documentation finale

---

## 📝 NOTES IMPORTANTES

### Gestion des Permissions
- **Teacher** : Accès aux séries où il enseigne
- **Bibliothecaire** : Scan QR uniquement
- **Surveillant Général** : Accès complet
- **Admin** : Accès total + configuration

### Format des Données
- Les champs `name`/`subname` sont les anciens champs
- Utiliser `first_name`/`last_name` pour les nouveaux Eleves
- Gérer la rétrocompatibilité avec un fallback

### Notifications WhatsApp
- Déjà intégré dans `SupervisorController`
- Réutiliser `WhatsAppService` existant
- Ne pas bloquer si échec de notification

### Cache & Performance
- Mettre en cache les listes d'Eleves (Redis)
- Pagination pour les grandes classes
- Optimiser les requêtes avec `eager loading`

---

## ✅ CHECKLIST DE VALIDATION

- [ ] Tous les endpoints répondent correctement
- [ ] L'authentification JWT fonctionne
- [ ] Les permissions par rôle sont respectées
- [ ] Les notifications WhatsApp sont envoyées
- [ ] Le frontend se connecte sans erreur
- [ ] Les présences sont enregistrées en base
- [ ] Les statistiques sont correctes
- [ ] La performance est acceptable (<2s par requête)

---

## 📞 SUPPORT & CONTACTS

- **Backend Lead** : [À définir]
- **Frontend Lead** : [À définir]
- **Documentation** : Ce fichier
- **API Testing** : Collection Postman disponible

---

*Document créé le : 10/01/2025*  
*Dernière mise à jour : 10/01/2025*  
*Version : 1.0*