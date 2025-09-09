#!/bin/bash
# COMMANDES RAPIDES POUR CORRIGER LE PROBLÈME DE PARSING

echo "🔧 Application rapide de la correction..."
echo ""

# 1. Backup des fichiers originaux
echo "📦 Création des backups..."
cp lib/models/api_response.dart lib/models/api_response.dart.backup
echo "✅ Backup créé: lib/models/api_response.dart.backup"

# 2. Appliquer la correction
echo ""
echo "🔄 Application de la correction..."
cp lib/models/api_response_corrected.dart lib/models/api_response.dart
echo "✅ Modèle ApiResponse corrigé appliqué"

# 3. Message de confirmation
echo ""
echo "========================================="
echo "✅ CORRECTION APPLIQUÉE AVEC SUCCÈS!"
echo "========================================="
echo ""
echo "📝 Prochaines étapes:"
echo "1. Relancez votre application: flutter run"
echo "2. Testez le chargement des sections"
echo "3. Observez les logs dans la console"
echo ""
echo "⚠️ Si vous voulez annuler:"
echo "   cp lib/models/api_response.dart.backup lib/models/api_response.dart"
echo ""
