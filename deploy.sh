#!/usr/bin/env bash
# Uso: ./deploy.sh "mensagem da atualização"
# Publica as páginas deste repositório diretamente (sem depender de ficheiros externos).
# Requer: chave SSH em keys/deploy_key (ou GIT_SSH_COMMAND predefinido) e remote 'origin' configurado.
set -e
cd "$(dirname "$0")"

# Fonte de verdade = os próprios ficheiros do repositório. Nada é copiado de fora.
# (Se existirem versões no workspace, podem ser sincronizadas manualmente antes.)

# Não usamos mais ficheiros fora do repo; garantimos que index e linhas-do-tempo ficam iguais
# por conveniência, mas cada um é commitado como está.
# (opcional) linha abaixo apenas para manter consistência; retire se quiser manter diferenciação
# cp index.html linhas-do-tempo.html

# Chave SSH: usa a que já existe (keys/deploy_key) ou a variável de ambiente
if [ -z "$GIT_SSH_COMMAND" ]; then
  if [ -f "$(pwd)/keys/deploy_key" ]; then
    export GIT_SSH_COMMAND="ssh -i $(pwd)/keys/deploy_key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
  fi
fi

git add -A
git commit -m "${1:-Atualização do site}" || echo "(nada novo para publicar)"
git branch -M main

# Push para o 'origin' já configurado (não recriamos o remote)
git push -u origin main 2>/dev/null || {
  # fallback: exigir que repo.conf/REPO exista apenas se o push falhar
  source repo.conf 2>/dev/null && git remote remove origin 2>/dev/null; git remote add origin "$REPO"; git push -u origin main
}
echo ""
echo "✓ Publicado. O GitHub Pages atualiza em ~1 minuto."
