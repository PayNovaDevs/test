#!/bin/bash
set -e

#############################
# CONFIG
#############################
BASE_DOMAIN="pay-nova.org"
BACK_DOMAIN="back.${BASE_DOMAIN}"
STUDIO_DOMAIN="studio.${BASE_DOMAIN}"
EMAIL_ADMIN="admin@${BASE_DOMAIN}"

INSTALL_DIR="/opt/supabase"
CREDS_FILE="/root/supabase-credentials.txt"

echo "🚀 SUPABASE CLEAN FINAL INSTALL (BACK DOMAIN)"
echo "--------------------------------------------"

#############################
# ROOT CHECK
#############################
if [ "$EUID" -ne 0 ]; then
  echo "❌ Ejecuta como root"
  exit 1
fi

#############################
# DEPENDENCIAS
#############################
apt update
apt install -y git nginx certbot python3-certbot-nginx openssl

command -v docker >/dev/null || { echo "❌ Docker no instalado"; exit 1; }
docker compose version >/dev/null || { echo "❌ Docker Compose no disponible"; exit 1; }

#############################
# LIMPIEZA TOTAL
#############################
echo "🧹 Eliminando instalaciones previas..."

docker rm -f $(docker ps -aq) 2>/dev/null || true
docker volume prune -f
rm -rf "${INSTALL_DIR}"
rm -f "${CREDS_FILE}"

#############################
# CLONAR SUPABASE
#############################
git clone https://github.com/supabase/supabase.git "${INSTALL_DIR}"
cd "${INSTALL_DIR}/docker"

#############################
# GENERAR SECRETS
#############################
JWT_SECRET=$(openssl rand -hex 32)
ANON_KEY=$(openssl rand -hex 32)
SERVICE_ROLE_KEY=$(openssl rand -hex 32)

POSTGRES_PASSWORD=$(openssl rand -hex 24)

SECRET_KEY_BASE=$(openssl rand -hex 64)
PG_META_CRYPTO_KEY=$(openssl rand -hex 32)

DASHBOARD_USERNAME="admin"
DASHBOARD_PASSWORD=$(openssl rand -base64 16)

#############################
# .ENV COMPLETO (VECTOR OK)
#############################
cat > .env <<EOF
############ GLOBAL ############
SITE_URL=https://${STUDIO_DOMAIN}
API_EXTERNAL_URL=https://${BACK_DOMAIN}
SUPABASE_PUBLIC_URL=https://${BACK_DOMAIN}

############ AUTH / JWT ############
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRY=3600
ANON_KEY=${ANON_KEY}
SERVICE_ROLE_KEY=${SERVICE_ROLE_KEY}

ENABLE_EMAIL_SIGNUP=false
ENABLE_PHONE_SIGNUP=false
ENABLE_ANONYMOUS_USERS=false
DISABLE_SIGNUP=false
ENABLE_EMAIL_AUTOCONFIRM=true
ENABLE_PHONE_AUTOCONFIRM=true

############ DATABASE ############
POSTGRES_HOST=db
POSTGRES_PORT=5432
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=postgres

############ POSTGREST ############
PGRST_DB_SCHEMAS=public

############ REALTIME ############
REALTIME_PORT=4000
REALTIME_EXTERNAL_URL=wss://${BACK_DOMAIN}/realtime/v1

############ FUNCTIONS ############
FUNCTIONS_VERIFY_JWT=true

############ STUDIO ############
STUDIO_PORT=3000
DASHBOARD_USERNAME=${DASHBOARD_USERNAME}
DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD}

############ KONG ############
KONG_HTTP_PORT=8000
KONG_HTTPS_PORT=8443

############ VECTOR / META ############
SECRET_KEY_BASE=${SECRET_KEY_BASE}
PG_META_CRYPTO_KEY=${PG_META_CRYPTO_KEY}

############ DOCKER ############
DOCKER_SOCKET_LOCATION=/var/run/docker.sock

############ LOGGING ############
LOGFLARE_PRIVATE_ACCESS_TOKEN=dummy
LOGFLARE_PUBLIC_ACCESS_TOKEN=dummy

############ MAILER ############
SMTP_HOST=localhost
SMTP_PORT=25
SMTP_USER=
SMTP_PASS=
MAILER_URLPATHS_INVITE=/auth/v1/verify
MAILER_URLPATHS_CONFIRMATION=/auth/v1/verify
EOF

#############################
# GUARDAR CREDENCIALES
#############################
cat > "${CREDS_FILE}" <<EOF
SUPABASE CREDENTIALS
===================

Backend URL: https://${BACK_DOMAIN}
Studio URL: https://${STUDIO_DOMAIN}

Studio User: ${DASHBOARD_USERNAME}
Studio Pass: ${DASHBOARD_PASSWORD}

JWT_SECRET: ${JWT_SECRET}
ANON_KEY: ${ANON_KEY}
SERVICE_ROLE_KEY: ${SERVICE_ROLE_KEY}

Postgres Password: ${POSTGRES_PASSWORD}

SECRET_KEY_BASE: ${SECRET_KEY_BASE}
PG_META_CRYPTO_KEY: ${PG_META_CRYPTO_KEY}
EOF

chmod 600 "${CREDS_FILE}"

#############################
# DOCKER UP
#############################
echo "🐳 Levantando Supabase..."
docker compose up -d

#############################
# NGINX
#############################
rm -f /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/supabase <<EOF
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 80;
    server_name ${BACK_DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
    }
}

server {
    listen 80;
    server_name ${STUDIO_DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
    }
}
EOF

ln -sf /etc/nginx/sites-available/supabase /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

#############################
# SSL
#############################
certbot --nginx \
  -d ${BACK_DOMAIN} \
  -d ${STUDIO_DOMAIN} \
  --non-interactive \
  --agree-tos \
  -m ${EMAIL_ADMIN}

#############################
# FINAL
#############################
echo ""
echo "✅ SUPABASE INSTALADO CORRECTAMENTE"
echo "---------------------------------"
echo "Backend: https://${BACK_DOMAIN}"
echo "Studio:  https://${STUDIO_DOMAIN}"
echo ""
echo "📄 Credenciales:"
echo "👉 ${CREDS_FILE}"
echo ""
echo "Instalación terminada SIN pasos extra."
echo "---------------------------------"
