#!/usr/bin/env bash
# Uso: ./deploy.sh "mensagem da atualização"
# Requer: variável REPO definida em repo.conf (ex.: git@github.com:utilizador/repo.git)
set -e
cd "$(dirname "$0")"
source repo.conf 2>/dev/null || { echo "ERRO: cria repo.conf com REPO=git@github.com:UTILIZADOR/REPO.git"; exit 1; }

# sincronizar a versão mais recente das páginas do workspace
cp ../linhas-do-tempo.html index.html 2>/dev/null || true
cp ../cronica-do-mundo.html cronica.html 2>/dev/null || true
cp ../linhas-do-tempo.html linhas-do-tempo.html 2>/dev/null || true

export GIT_SSH_COMMAND="ssh -i $(pwd)/keys/deploy_key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
git add -A
git commit -m "${1:-Atualização do site}" || echo "(nada novo para publicar)"
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO"
git push -u origin main
echo ""
echo "✓ Publicado. O GitHub Pages atualiza em ~1 minuto."
