#!/usr/bin/env bash
# Envoie le code sur Infomaniak via SSH/rsync (depuis le Mac).
# Usage : ./deploy/deploy.sh          (envoi réel)
#         ./deploy/deploy.sh --dry    (simulation, n'envoie rien)
set -euo pipefail

# À ADAPTER (Manager Infomaniak > Hébergement > FTP / SSH)
SSH_USER="XXXX_user"
SSH_HOST="XXXX.ftp.infomaniak.com"
REMOTE_DIR="sites/progserv2"   # dossier du site ; son sous-dossier public/ = racine web

DRY=""
[[ "${1:-}" == "--dry" ]] && DRY="--dry-run" && echo ">> Simulation"

cd "$(dirname "$0")/.."

rsync -avz --delete $DRY \
  --exclude '.git/' --exclude '.gitignore' --exclude '.env' \
  --exclude 'docker/' --exclude 'docker-compose.yml' \
  --exclude 'maquette/' --exclude 'bdd/' --exclude 'deploy/' \
  --exclude '*.md' --exclude '.DS_Store' \
  --exclude 'config.local.php' \
  ./ "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"

echo ">> Terminé. Test : https://progserv2.laurenternst.ch"
