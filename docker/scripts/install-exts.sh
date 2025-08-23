#!/usr/bin/env bash
set -euo pipefail

log() { echo -e "\n\033[1;34m>>> $*\033[0m"; }
fail() { echo -e "\n\033[1;31m!!! $*\033[0m"; exit 1; }

log "Updating apt cache..."
apt-get update || fail "apt-get update failed"

log "Installing base tools (unzip, curl)..."
apt-get install -y --no-install-recommends unzip curl || fail "Failed to install unzip/curl"

log "Installing PHP build deps (\$PHPIZE_DEPS)..."
apt-get install -y --no-install-recommends $PHPIZE_DEPS || fail "Failed to install PHP build deps"

log "Installing GD deps..."
apt-get install -y --no-install-recommends libpng-dev libjpeg62-turbo-dev libfreetype6-dev || fail "Failed to install GD deps"

log "Installing ZIP deps..."
apt-get install -y --no-install-recommends libzip-dev || fail "Failed to install ZIP deps"

log "Installing INTL deps..."
apt-get install -y --no-install-recommends libicu-dev || fail "Failed to install INTL deps"

log "Installing SOAP deps..."
apt-get install -y --no-install-recommends libxml2-dev || fail "Failed to install SOAP deps"

log "Enabling Apache mod_rewrite..."
a2enmod rewrite || fail "Failed to enable mod_rewrite"

log "Installing pdo + pdo_mysql..."
docker-php-ext-install -j"$(nproc)" pdo pdo_mysql || fail "pdo/pdo_mysql build failed"

log "Configuring + installing GD..."
docker-php-ext-configure gd --with-freetype --with-jpeg || fail "gd configure failed"
docker-php-ext-install -j"$(nproc)" gd || fail "gd build failed"

log "Installing zip..."
docker-php-ext-install -j"$(nproc)" zip || fail "zip build failed"

log "Installing Oniguruma (for mbstring)..."
apt-get install -y --no-install-recommends libonig-dev || fail "Failed to install libonig-dev"

log "Installing mbstring..."
docker-php-ext-install -j"$(nproc)" mbstring || fail "mbstring build failed"

log "Installing intl..."
docker-php-ext-install -j"$(nproc)" intl || fail "intl build failed"

log "Installing soap..."
docker-php-ext-install -j"$(nproc)" soap || fail "soap build failed"

log "Installing mariadb-client..."
apt-get install -y --no-install-recommends mariadb-client || fail "Failed to install mariadb-client"

log "Cleaning apt cache..."
rm -rf /var/lib/apt/lists/*

log "All extensions installed successfully!"
