#!/usr/bin/env bash
set -euo pipefail

SENTRIFUGO_VERSION="${1:-3.2}"
DOWNLOAD_URL="https://sourceforge.net/projects/sentrifugo/files/Sentrifugo-v${SENTRIFUGO_VERSION}.zip/download"

echo ">>> Downloading Sentrifugo v${SENTRIFUGO_VERSION}..."
curl -L -o /tmp/sentrifugo.zip "$DOWNLOAD_URL"

echo ">>> Extracting..."
unzip -q /tmp/sentrifugo.zip -d /usr/src/

rm -f /tmp/sentrifugo.zip

# Normalize directory name
mv /usr/src/Sentrifugo* /usr/src/sentrifugo

# Permissions
chown -R www-data:www-data /usr/src/sentrifugo

echo ">>> Sentrifugo v${SENTRIFUGO_VERSION} ready at /usr/src/sentrifugo"
