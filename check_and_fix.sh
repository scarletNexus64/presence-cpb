#!/bin/bash

# Script de vérification et correction automatique du problème de parsing
# Utilisation: bash check_and_fix.sh

echo "🔍 ========================================="
echo "   VÉRIFICATION DU PROBLÈME DE PARSING"
echo "========================================="
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Chemins des fichiers
API_RESPONSE_FILE="lib/models/api_response.dart"
SECTIONS_SCREEN_FILE="lib/screens/student/sections_screen.dart"

echo "📂 Vérification de la structure du projet..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter${NC}"
    echo "   Répertoire actuel: $(pwd)"
    exit 1
fi

echo -e "${GREEN}✅ Structure du projet Flutter détectée${NC}"
echo ""

# Fonction pour vérifier un fichier
check_file() {
    local file=$1
    local search_pattern=$2
    local file_description=$3
    
    echo "🔍 Vérification de $file_description..."
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Fichier non trouvé: $file${NC}"
        return 1
    fi
    
    if grep -q "$search_pattern" "$file"; then
        echo -e "${RED}⚠️  Problème détecté dans $file${NC}"
        echo "   Pattern trouvé: $search_pattern"
        return 1
    else
        echo -e "${GREEN}✅ $file_description semble correct${NC}"
        return 0
    fi
}

# Vérifier api_response.dart
echo "📋 === Vérification du modèle ApiResponse ==="
if check_file "$API_RESPONSE_FILE" "Map<String, dynamic>? data" "ApiResponse model"; then
    echo -e "${GREEN}✅ Le modèle ApiResponse est déjà corrigé${NC}"
else
    echo -e "${YELLOW}⚠️  Le modèle ApiResponse doit être corrigé${NC}"
    echo ""
    echo "📝 Correction nécessaire dans $API_RESPONSE_FILE:"
    echo "   Remplacer: final Map<String, dynamic>? data;"
    echo "   Par:       final dynamic data;"
    echo ""
    
    # Proposer une correction automatique
    read -p "Voulez-vous créer une copie corrigée? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$API_RESPONSE_FILE" "${API_RESPONSE_FILE}.backup"
        echo -e "${GREEN}✅ Backup créé: ${API_RESPONSE_FILE}.backup${NC}"
        
        # Créer le fichier corrigé
        cat > "${API_RESPONSE_FILE}.corrected" << 'EOF'
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data; // Changé pour accepter List et Map
  final int? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errorCode: json['error_code'],
    );
  }

  factory ApiResponse.error(String message, {int? errorCode}) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  factory ApiResponse.success(String message, {dynamic data}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  // Méthodes helper pour faciliter l'utilisation
  List<dynamic> get dataAsList => data is List ? data as List<dynamic> : [];
  Map<String, dynamic> get dataAsMap => data is Map ? data as Map<String, dynamic> : {};
  bool get hasListData => data is List && (data as List).isNotEmpty;
  bool get hasMapData => data is Map && (data as Map).isNotEmpty;
}
EOF
        echo -e "${GREEN}✅ Fichier corrigé créé: ${API_RESPONSE_FILE}.corrected${NC}"
        echo ""
        echo "Pour appliquer la correction:"
        echo "  mv ${API_RESPONSE_FILE}.corrected ${API_RESPONSE_FILE}"
    fi
fi

echo ""
echo "📋 === Vérification de sections_screen.dart ==="

# Vérifier si le cast problématique est présent
if grep -q "as Map<String, dynamic>" "$SECTIONS_SCREEN_FILE"; then
    echo -e "${YELLOW}⚠️  Cast potentiellement problématique détecté dans sections_screen.dart${NC}"
    echo "   Assurez-vous d'utiliser: response.data as List<dynamic>"
    echo "   ou la méthode helper: response.dataAsList"
fi

echo ""
echo "🔧 === Recommandations ==="
echo ""
echo "1. Corrigez d'abord api_response.dart"
echo "2. Mettez à jour sections_screen.dart pour utiliser:"
echo "   - response.dataAsList (recommandé)"
echo "   - ou response.data as List<dynamic>"
echo "3. Relancez l'application avec: flutter run"
echo "4. Observez les logs pour confirmer la résolution"
echo ""

# Vérifier si Flutter est installé
if command -v flutter &> /dev/null; then
    echo "📱 === Test rapide ==="
    read -p "Voulez-vous analyser le projet Flutter? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Analyse du projet en cours..."
        flutter analyze --no-fatal-warnings | head -20
    fi
else
    echo -e "${YELLOW}⚠️  Flutter n'est pas détecté dans le PATH${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}✅ Vérification terminée${NC}"
echo "========================================="
echo ""
echo "📚 Pour plus d'informations, consultez:"
echo "   - CORRECTION_GUIDE.md"
echo "   - test_debug_sections.dart"
echo ""
