#!/usr/bin/env bash
# =============================================================================
# setup-fly.sh — Configuration initiale Fly.io pour le backend Violette
# =============================================================================
# Prérequis :
#   - flyctl installé : https://fly.io/docs/hands-on/install-flyctl/
#   - Compte Fly.io créé et authentifié : fly auth login
#   - Base MySQL Aiven créée et accessible (cf. README-deploiement.md)
#
# Usage :
#   bash setup-fly.sh
# =============================================================================
set -euo pipefail

APP_NAME="violette-back"
REGION="cdg"
FLY_TOML_DIR="violette-back"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       Configuration initiale Fly.io — Backend Violette       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""



echo "✅ flyctl détecté : $(flyctl version --json 2>/dev/null | grep -oP '(?<=\"Version\":\")[^\"]+' || flyctl version | head -1)"
echo "✅ Authentifié en tant que : $(flyctl auth whoami)"
echo ""

# --- Étape 1 : Création de l'application ---
echo "━━━ Étape 1/4 : Création de l'application Fly.io ━━━"
if flyctl apps list 2>/dev/null | grep -q "^$APP_NAME "; then
  echo "ℹ️  L'application '$APP_NAME' existe déjà — étape ignorée."
else
  flyctl apps create "$APP_NAME" --machines
  echo "✅ Application '$APP_NAME' créée dans la région '$REGION'."
fi
echo ""

# --- Étape 2 : Injection des secrets Aiven MySQL ---
echo "━━━ Étape 2/4 : Configuration des secrets MySQL (Aiven) ━━━"
echo ""
echo "Récupère ces informations depuis : https://console.aiven.io/"
echo "  Service MySQL → Overview → Connection information"
echo ""

read -rp "Host Aiven (ex: mysql-xxxx.aivencloud.com)  : " AIVEN_HOST
read -rp "Port Aiven (ex: 12345)                       : " AIVEN_PORT
read -rp "Nom de la base (ex: violette_db)             : " AIVEN_DB
read -rp "Utilisateur Aiven (ex: avnadmin)             : " AIVEN_USER
read -rsp "Mot de passe Aiven                           : " AIVEN_PASS
echo ""

JDBC_URL="jdbc:mysql://${AIVEN_HOST}:${AIVEN_PORT}/${AIVEN_DB}?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&sslMode=REQUIRED"

echo ""
echo "JDBC URL construite : $JDBC_URL"
echo ""

flyctl secrets set \
  "QUARKUS_DATASOURCE_JDBC_URL=${JDBC_URL}" \
  "QUARKUS_DATASOURCE_USERNAME=${AIVEN_USER}" \
  "QUARKUS_DATASOURCE_PASSWORD=${AIVEN_PASS}" \
  --app "$APP_NAME"

echo "✅ Secrets MySQL injectés."
echo ""

# --- Étape 3 : Premier déploiement ---
echo "━━━ Étape 3/4 : Premier déploiement ━━━"
echo "Déploiement depuis fly.toml (image GHCR :latest)..."
echo ""

cd "$FLY_TOML_DIR"
flyctl deploy --wait-timeout 180
cd ..

echo ""
echo "✅ Déploiement terminé."
echo ""
echo "🌐 Backend disponible sur : https://${APP_NAME}.fly.dev"
echo "🏓 Health check          : https://${APP_NAME}.fly.dev/api/ping"
echo "📖 Swagger UI            : https://${APP_NAME}.fly.dev/swagger-ui"
echo ""

# --- Étape 4 : Génération du FLY_API_TOKEN pour GitHub Actions ---
echo "━━━ Étape 4/4 : Génération du token GitHub Actions (FLY_API_TOKEN) ━━━"
echo ""
echo "Génération d'un deploy token dédié au CI/CD..."
echo ""

flyctl tokens create deploy --name "github-actions-${APP_NAME}" --app "$APP_NAME"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    ✅ Configuration terminée                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Action manuelle requise :"
echo "  Copier le token affiché ci-dessus et l'ajouter dans :"
echo "  GitHub → Settings → Secrets and variables → Actions"
echo "  Nom du secret : FLY_API_TOKEN"
echo ""
echo "Ensuite, chaque push sur 'main' déclenchera un déploiement automatique."
