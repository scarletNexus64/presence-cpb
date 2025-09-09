#!/bin/bash

# Script de test rapide pour vérifier la connexion
BASE_URL="http://192.168.1.119:8001"

echo "🔍 Test de connexion au système de présence CPB"
echo "=============================================="

# Test 1: Vérifier que le serveur répond
echo ""
echo "1️⃣ Test de base - Serveur accessible"
curl -s -w "Status: %{http_code}\n" "$BASE_URL/api/test" || echo "❌ Serveur non accessible"

echo ""
echo "2️⃣ Test endpoint sans authentification"
curl -s -X POST "$BASE_URL/api/test/scan-qr-no-auth" \
  -H "Content-Type: application/json" \
  -d '{
    "staff_qr_code": "TEST_QR",
    "supervisor_id": 1,
    "test_data": "Test depuis script bash"
  }' | jq '.' 2>/dev/null || echo "❌ Endpoint test non accessible"

echo ""
echo "3️⃣ Test de connexion avec username/password"
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "biblio_test",
    "password": "password123"
  }')

echo "Réponse de connexion:"
echo "$TOKEN_RESPONSE" | jq '.' 2>/dev/null || echo "$TOKEN_RESPONSE"

# Extraire le token si connexion réussie
TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    echo ""
    echo "4️⃣ Test avec token JWT"
    curl -s -X POST "$BASE_URL/api/test/scan-qr-with-debug-auth" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "test_data": "Test JWT depuis script"
      }' | jq '.' 2>/dev/null || echo "❌ Test JWT échoué"
      
    echo ""
    echo "5️⃣ Test staff attendance complet"
    curl -s -X POST "$BASE_URL/api/test/staff-attendance-debug" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "staff_qr_code": "STAFF_1",
        "supervisor_id": 1,
        "event_type": "entry"
      }' | jq '.' 2>/dev/null || echo "❌ Test staff attendance échoué"
else
    echo "❌ Pas de token reçu - vérifiez les credentials ou créez l'utilisateur de test"
fi

echo ""
echo "✅ Tests terminés"
echo ""
echo "Pour créer l'utilisateur de test:"
echo "php artisan tinker"
echo "puis:"
echo "\$user = new App\\Models\\User();"
echo "\$user->name = 'Test Bibliothecaire';"
echo "\$user->username = 'biblio_test';"
echo "\$user->email = 'biblio@test.com';"
echo "\$user->password = Hash::make('password123');"
echo "\$user->role = 'bibliothecaire';"
echo "\$user->is_active = true;"
echo "\$user->save();"