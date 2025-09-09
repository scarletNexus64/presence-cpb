# Guide de Test - Interface Eleves

## 🚀 Comment tester l'interface

### 1. Démarrage de l'application

```bash
cd /Users/macbookpro/Desktop/Developments/Personnals/Scan/presence_cpb
flutter run
```

### 2. Flow de test complet

#### A. Écran de Login
1. **Ouvrez l'app** → Vous arrivez sur le SplashScreen puis Login
2. **Sélectionnez le mode** :
   - `Auto` : Vous serez redirigé vers la sélection de profil
   - `Eleves` : Vous irez directement à l'interface verte Eleves ✅
   - `Enseignants` : Interface bleue classique

3. **Connectez-vous** avec vos identifiants existants

#### B. Interface Eleves (Thème Vert)
1. **Accueil Eleves** 
   - Vérifiez le thème vert
   - Cliquez sur "Mode Manuel"
   - Le mode automatique affiche "Bientôt"

2. **Navigation Hiérarchique**
   ```
   Sections (Cycles) → Niveaux → Classes → Séries → Élèves
   ```
   - Maternelle → PS/MS/GS
   - Primaire → CP/CE1/CE2/CM1/CM2  
   - Secondaire → 6ème/5ème/4ème/3ème
   - Lycée → 2nde/1ère/Terminale

3. **Sélection d'une série**
   - Choisissez par exemple : Primaire → CP → CP A → Série Unique
   - Vous verrez la liste des élèves (données mock)

4. **Prise de présence**
   - **Mode sélectionnable** : Entrée (vert) ou Sortie (orange)
   - **Marquage individuel** : Boutons Présent/Absent pour chaque élève
   - **Statistiques temps réel** : Compteurs présents/absents/à faire
   - **Validation** : Bouton "Valider l'appel"

### 3. Tests spécifiques

#### A. Test Navigation
- ✅ Retour possible à chaque étape
- ✅ Breadcrumb visible dans les headers
- ✅ Données cohérentes entre les écrans

#### B. Test Présences
- ✅ Changement de mode Entrée/Sortie
- ✅ Marquage/démarquage des élèves
- ✅ Statistiques mises à jour en temps réel
- ✅ Dialogue de confirmation si élèves non marqués
- ✅ Dialogue de fin avec options (Autre classe / Accueil)

#### C. Test UI/UX
- ✅ Thème vert distinctif de l'interface enseignants
- ✅ Animations fluides
- ✅ États visuels clairs (présent=vert, absent=rouge, non marqué=gris)
- ✅ Responsive design

#### D. Test API (avec backend)
Si votre backend est connecté :
- ✅ Chargement des vraies sections depuis `/api/sections`
- ✅ Navigation avec vraies données
- ✅ Soumission des présences vers `/api/attendance/students/submit`
- ✅ Fallback vers données mock si API indisponible

### 4. Points de vérification

#### Interface Utilisateur
- [ ] Couleurs vertes bien appliquées
- [ ] Icônes contextuelles appropriées
- [ ] Textes et labels corrects
- [ ] Boutons responsive au touch
- [ ] Messages d'erreur clairs

#### Fonctionnalités
- [ ] Navigation fluide
- [ ] Sélection de mode (entrée/sortie)
- [ ] Marquage présences fonctionnel
- [ ] Statistiques exactes
- [ ] Sauvegarde réussie (ou simulation)

#### Performance
- [ ] Chargement rapide des écrans
- [ ] Pas de lag lors du marquage
- [ ] Mémoire stable
- [ ] Transitions smooth

### 5. Scénarios de test avancés

#### Scénario 1 : Appel du matin complet
1. Login → Mode Eleves
2. Primaire → CE1 → CE1 B → Série Unique
3. Mode Entrée
4. Marquer 20 présents, 5 absents, laisser 3 non marqués
5. Valider → Confirmer les non marqués
6. Choisir "Autre classe" → Tester classe suivante

#### Scénario 2 : Changement de mode
1. Arriver sur une liste d'élèves
2. Changer Entrée → Sortie
3. Vérifier changement couleur (vert → orange)
4. Marquer quelques présences
5. Valider l'appel de sortie

#### Scénario 3 : Test d'erreur
1. Désactiver WiFi/Data
2. Essayer de charger une section
3. Vérifier fallback vers données mock
4. Reactiver réseau
5. Réessayer

### 6. Debug et logs

Si vous avez des problèmes :

```bash
# Logs détaillés
flutter run --verbose

# Hot reload pour les modifications
# Dans le terminal : r (reload) ou R (restart)

# Inspecter les états
# Ajouter des print() dans les méthodes setState()
```

### 7. Structure des fichiers créés

```
lib/screens/student/
├── student_home_screen.dart     ✅ Accueil vert
├── sections_screen.dart         ✅ Cycles
├── levels_screen.dart          ✅ Niveaux
├── classes_screen.dart         ✅ Classes  
├── series_screen.dart          ✅ Séries
├── students_list_screen.dart   ✅ Liste élèves
└── attendance_screen.dart      ✅ Prise présence

lib/services/
└── student_api_service.dart    ✅ API service

lib/models/
└── student.dart               ✅ Modèles données
```

### 8. Prochaines étapes après test

Une fois les tests validés :
1. **Intégration backend** complète
2. **Mode automatique** avec QR codes  
3. **Interface web** d'administration
4. **Synchronisation** temps réel
5. **Notifications** push

---

**🎯 Objectif du test** : Valider que l'interface étudiante fonctionne parfaitement en mode manuel avant d'ajouter le mode automatique QR.

**📱 Compatibilité** : Testé sur Android/iOS avec Flutter 3.x

**🔧 Support** : En cas de problème, vérifiez les logs console et les messages d'erreur dans l'app.
