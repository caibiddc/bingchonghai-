#!/usr/bin/env bash
set -euo pipefail
test "${GITHUB_ACTIONS:-}" = "true" || exit 2
git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git switch -c staging/web-backend-ai
import() {
 git remote add "$1" "$2"
 git fetch --no-tags "$1" "+refs/heads/$3:refs/remotes/$1/$3"
 git subtree add --prefix="$4" "$1/$3" -m "chore: import $1 preserving complete history"
}
import web https://github.com/mmdxiaoxin/agricultural-diagnostic-web.git main apps/web
import backend https://github.com/mmdxiaoxin/agricultural-diagnostic-service.git master apps/backend
import ai https://github.com/mmdxiaoxin/agricultural-ai-service.git master services/ai
# Reuse narrowly reviewed fixes from source consolidation branch, not mobile files.
git remote add review https://github.com/caibiddc/AgriculturalDiagnosticApp.git
git fetch --no-tags review "+refs/heads/integration/full-platform:refs/remotes/review/integration/full-platform"
for path in \
 apps/web/vite.config.ts \
 apps/backend/Dockerfile \
 apps/backend/.dockerignore \
 apps/backend/docker-compose.yml \
 apps/backend/package.json \
 apps/backend/apps/auth-service/src/modules/auth/auth.service.ts \
 apps/backend/apps/auth-service/src/modules/auth/__test__/auth.service.spec.ts \
 services/ai/docker-compose.yml \
 services/ai/config/app_config.py \
 services/ai/common/utils/jwt_utils.py \
 services/ai/modules/health/routes.py \
 services/ai/tests/test_auth_context.py; do
 mkdir -p "$(dirname "$path")"
 git show "review/integration/full-platform:$path" > "$path"
done
cat > README.md <<'EOF'
# 农作物病虫害诊断平台（Web / Backend / AI）

- `apps/web`: React / Vite 前端
- `apps/backend`: NestJS API 网关与微服务
- `services/ai`: Flask / Celery / PyTorch 诊断推理

移动应用维护在独立仓库： https://github.com/caibiddc/AgriculturalDiagnosticApp

原仓库所有提交历史均以未压缩的 git subtree 方式保留。

尚未完成学校正式漏洞扫描、GPU 模型与全链路验收，禁止在公网直接暴露数据库/Redis/微服务端口。
EOF
cat > .gitignore <<'EOF'
**/node_modules/
**/dist/
**/__pycache__/
**/*.pyc
**/.env
**/.env.*
!**/.env.example
**/.venv/
*.pem
*.key
EOF
git add -A
git commit -m 'fix: import verified web backend and AI service corrections'
for spec in 'web main' 'backend master' 'ai master'; do
 read -r name source_branch <<< "$spec"
 git merge-base --is-ancestor "$name/$source_branch" HEAD
done
echo 'All three histories preserved'
git push -u origin staging/web-backend-ai
