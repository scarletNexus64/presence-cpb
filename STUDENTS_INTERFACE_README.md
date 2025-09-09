# Interface de Gestion des Présences Eleves

## 🎯 Objectif

Cette interface permet la gestion des présences des élèves via une application mobile Flutter avec un thème vert distinctif.

## 🔄 Flux de Navigation

### 1. Login Screen
- **Sélection du mode** : Auto, Enseignants, ou Eleves
- **Navigation intelligente** selon le mode choisi :
  - `Auto` → Écran de sélection de profil
  - `Enseignants` → Interface enseignants (bleu)
  - `Eleves` → Interface Eleves (vert)

### 2. Interface Eleves (Thème Vert)
```
StudentHomeScreen
    ↓
SectionsScreen (Cycles)
    ↓
LevelsScreen (Niveaux)
    ↓
ClassesScreen (Classes)
    ↓
SeriesScreen (Séries)
    ↓
StudentsListScreen (Liste élèves)
    ↓
AttendanceScreen (Prise de présence)
```

## 📱 Fonctionnalités

### Mode Manuel
- **Navigation hiérarchique** : Section → Niveau → Classe → Série → Élèves
- **Deux types d'appel** :
  - 🟢 **Entrée** : Appel du matin
  - 🟠 **Sortie** : Appel du soir
- **Interface intuitive** : 
  - Boutons Présent/Absent pour chaque élève
  - Statistiques en temps réel
  - Validation globale de l'appel

### Mode Automatique (À venir)
- Scan des cartes QR des élèves
- Enregistrement automatique des présences

## 🎨 Design

### Couleurs Principales
- **Vert** : Interface Eleves (#4CAF50, #66BB6A, #81C784)
- **Bleu** : Interface enseignants (conservé)

### Composants UI
- **Cards modernes** avec ombres et bordures colorées
- **Animations fluides** avec `AnimationController`
- **États visuels** clairs (présent/absent/non marqué)
- **Icônes contextuelles** pour chaque section

## 🔧 Structure Technique

### Écrans Principaux
```
lib/screens/student/
├── student_home_screen.dart    # Accueil mode Eleves
├── sections_screen.dart        # Sélection des cycles
├── levels_screen.dart          # Sélection des niveaux  
├── classes_screen.dart         # Sélection des classes
├── series_screen.dart          # Sélection des séries
├── students_list_screen.dart   # Liste des élèves
└── attendance_screen.dart      # Prise de présence
```

### Services API
```
lib/services/
├── student_api_service.dart    # API pour gestion Eleves
└── attendance_api_service.dart # API existante enseignants
```

### Modèles de Données
```
lib/models/
└── student.dart               # Modèles Student, ClassSeries, etc.
```

## 🌐 API Backend

### Endpoints Utilisés
- `GET /api/sections` - Liste des sections/cycles
- `GET /api/sections/{id}/levels` - Niveaux d'une section
- `GET /api/levels/{id}/classes` - Classes d'un niveau
- `GET /api/classes/{id}/series` - Séries d'une classe
- `GET /api/students/series/{id}` - Élèves d'une série
- `POST /api/attendance/students/submit` - Soumettre les présences

### Structure de Soumission
```json
{
  "series_id": 123,
  "event_type": "entry", // ou "exit"
  "attendance_date": "2024-01-15T00:00:00Z",
  "students": [
    {
      "student_id": 456,
      "is_present": true,
      "student_number": "20240001"
    }
  ],
  "notes": "Appel du matin"
}
```

## 🚀 Utilisation

### Démarrage Rapide
1. **Login** → Sélectionner "Mode Eleves"
2. **Navigation** → Parcourir Cycle → Niveau → Classe → Série
3. **Appel** → Sélectionner Entrée/Sortie
4. **Marquage** → Cocher Présent/Absent pour chaque élève
5. **Validation** → Confirmer et enregistrer

### Workflow Typique
```
📱 Surveillant arrive le matin
└─ Sélectionne "Mode Eleves"
└─ Choisit "Primaire" → "CP" → "CP A" → "Série Unique"
└─ Active "Appel d'Entrée"
└─ Marque les présences élève par élève
└─ Valide l'appel → Passe à la classe suivante
```

## 🔄 États et Feedback

### Indicateurs Visuels
- **🟢 Présent** : Card verte, icône check
- **🔴 Absent** : Card rouge, icône croix  
- **🟠 Non marqué** : Card grise, icône question

### Statistiques Temps Réel
- Nombre total d'élèves
- Nombre de présents
- Nombre d'absents  
- Pourcentage de présence
- Progression de l'appel

## 📝 Prochaines Étapes

### Phase 1 (Actuelle) ✅
- Interface mobile complète
- Mode manuel fonctionnel
- Thème vert distinctif
- Navigation hiérarchique

### Phase 2 (À venir)
- Intégration API réelle
- Mode automatique avec QR codes
- Synchronisation temps réel
- Interface web d'administration

### Phase 3 (Futur)
- Notifications push
- Rapports de présence
- Analytics avancées
- Mode hors ligne

## 🎯 Avantages

1. **Séparation claire** : Interface dédiée aux Eleves (vert) vs enseignants (bleu)
2. **Navigation intuitive** : Flux logique Section → Série → Élèves
3. **Flexibilité** : Support entrée ET sortie
4. **Efficacité** : Validation en lot avec statistiques
5. **Évolutivité** : Prêt pour le mode automatique QR

---

*Interface développée pour CPB Douala - Gestion moderne des présences étudiantes* 🎓
