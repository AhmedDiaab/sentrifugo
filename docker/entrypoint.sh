#!/usr/bin/env bash
set -e

APP_DIR=/var/www/html/sentrifugo
SRC_DIR=/usr/src/sentrifugo
HOTFIX_SQL=${HOTFIX_SQL:-/hotfix/hotfix-permissions.sql}
DB_HOST=${DB_HOST:-db}
DB_ROOT_USER=${DB_ROOT_USER:-root}
DB_ROOT_PASS=${DB_ROOT_PASS:-rootpass}
DB_WAIT_TIMEOUT=${DB_WAIT_TIMEOUT:-120}   # second

# 1) First-run seed
if [ -z "$(ls -A "$APP_DIR" 2>/dev/null || true)" ]; then
  echo "Seeding Sentrifugo into $APP_DIR (first run)..."
  cp -a "$SRC_DIR"/. "$APP_DIR"/
fi

# 2) Fix ownership
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 /var/www/html/sentrifugo/logs
touch /var/www/html/sentrifugo/logs/application.log
chown www-data:www-data /var/www/html/sentrifugo/logs/application.log
chmod 664 /var/www/html/sentrifugo/logs/application.log

# 3) PHP 8 patch for legacy PHPMailer autoloader  <<--- PUT YOUR BLOCK HERE
# f="$APP_DIR/install/PHPMailer/PHPMailerAutoload.php"
# if [ -f "$f" ] && grep -q "__autoload" "$f"; then
#   echo "Patching legacy __autoload in PHPMailerAutoload.php..."
#   sed -i 's/function __autoload/function legacy_autoload/' "$f"
#   printf "\n%s\n" "spl_autoload_register('legacy_autoload', true, true);" >> "$f"
# fi

# STEP4="$APP_DIR/install/step4.php"
# if [ -f "$STEP4" ] && ! grep -q "PHPMailerAutoload.php" "$STEP4"; then
#   echo "Patching step4.php to require PHPMailerAutoload.php..."
#   # insert a require_once right after the opening <?php
#   awk '
#     BEGIN{ins=0}
#     ins==0 && /^<\?php/ { print; print "require_once __DIR__.\x27/PHPMailer/PHPMailerAutoload.php\x27;"; ins=1; next }
#     { print }
#   ' "$STEP4" > "${STEP4}.patched" && mv "${STEP4}.patched" "$STEP4"
# fi

# 4) Optional DB hotfix (only if mysql client exists and file is present)
if command -v mysqladmin >/dev/null 2>&1 && command -v mysql >/dev/null 2>&1 && [ -f "$HOTFIX_SQL" ]; then
  echo "Waiting for DB at ${DB_HOST} (timeout ${DB_WAIT_TIMEOUT}s)..."
  SECONDS=0
  until mysqladmin ping -h "${DB_HOST}" -u"${DB_ROOT_USER}" -p"${DB_ROOT_PASS}" --silent; do
    if (( SECONDS >= DB_WAIT_TIMEOUT )); then
      echo "ERROR: DB not available after ${DB_WAIT_TIMEOUT}s"; break
    fi
    sleep 2
  done

  if mysqladmin ping -h "${DB_HOST}" -u"${DB_ROOT_USER}" -p"${DB_ROOT_PASS}" --silent; then
    if [ ! -f "$APP_DIR/.hotfix_applied" ]; then
      echo "Applying DB hotfix from ${HOTFIX_SQL}..."
      mysql -h "${DB_HOST}" -u"${DB_ROOT_USER}" -p"${DB_ROOT_PASS}" < "${HOTFIX_SQL}" \
        && touch "$APP_DIR/.hotfix_applied" \
        && echo "Hotfix applied."
    else
      echo "Hotfix already applied. Skipping."
    fi
  fi
else
  echo "DB hotfix skipped (mysql client or SQL file missing)."
fi

# 5) Hand off to Apache
exec "$@"
