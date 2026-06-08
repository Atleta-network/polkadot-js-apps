#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  echo "Atleta customization guard failed: $*" >&2
  exit 1
}

require_file() {
  local file="$1"
  [ -f "${file}" ] || fail "missing ${file}"
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  require_file "${file}"
  grep -Eq "${pattern}" "${file}" || fail "${description} is missing in ${file}"
}

reject_pattern() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  require_file "${file}"
  if grep -Eq "${pattern}" "${file}"; then
    fail "${description} must not be present in ${file}"
  fi
}

require_file ".github/workflows/build_and_release_image.yml"
require_file ".github/workflows/deploy_service.yml"
require_file ".github/actions/deploy-over-ssh/action.yml"
require_file ".github/actions/check-image-exists/action.yml"
require_file ".github/actions/resolve-service-tag/action.yml"

require_pattern ".github/workflows/build_and_release_image.yml" "branches:[[:space:]]*$" "push branch section"
require_pattern ".github/workflows/build_and_release_image.yml" "atleta" "atleta branch build trigger"
require_pattern ".github/workflows/build_and_release_image.yml" "TARGET_ENV=\"dev\"" "atleta push maps to dev"
require_pattern ".github/workflows/build_and_release_image.yml" "AUTO_DEPLOY_DEV" "dev auto deploy feature flag"
require_pattern ".github/workflows/build_and_release_image.yml" "repository-dispatch@v4\\.0\\.1" "dev auto deploy dispatch"
require_pattern ".github/workflows/build_and_release_image.yml" "Prod deploy is manual-only" "manual-only prod deployment"
require_pattern ".github/workflows/build_and_release_image.yml" "docker/build-push-action@v7\\.2\\.0" "current Docker build action"
require_pattern ".github/workflows/build_and_release_image.yml" "actions/checkout@v6" "current checkout action"
require_pattern ".github/workflows/build_and_release_image.yml" "polkadot-js-apps-build" "build concurrency"

require_pattern ".github/workflows/deploy_service.yml" "confirm_prod" "explicit prod confirmation input"
require_pattern ".github/workflows/deploy_service.yml" "DEPLOY_PROD" "explicit prod confirmation value"
require_pattern ".github/workflows/deploy_service.yml" "repository_dispatch" "dev deploy repository dispatch"
require_pattern ".github/workflows/deploy_service.yml" "Prod deploy is manual-only" "repository dispatch prod protection"
require_pattern ".github/workflows/deploy_service.yml" "COMPOSE_SERVICE_NAME" "compose service variable support"
require_pattern ".github/workflows/deploy_service.yml" "polkadot-js-apps-deploy" "deploy concurrency"
require_pattern ".github/workflows/deploy_service.yml" "actions/checkout@v6" "current checkout action"

require_pattern ".github/actions/deploy-over-ssh/action.yml" "docker compose -f \"\\$\\{DOCKER_COMPOSE_FILE\\}\" config --quiet" "remote compose validation"
require_pattern ".github/actions/deploy-over-ssh/action.yml" "flock -w 900" "remote deploy lock"
require_pattern ".github/actions/deploy-over-ssh/action.yml" "docker compose -f \"\\$\\{DOCKER_COMPOSE_FILE\\}\" up -d --force-recreate \"\\$\\{COMPOSE_SERVICE\\}\"" "service-only compose recreate"
require_pattern ".github/actions/deploy-over-ssh/action.yml" "wait_for_container" "post-deploy container wait"
require_pattern ".github/actions/deploy-over-ssh/action.yml" "docker exec nginx nginx -t" "nginx validation before reload"
reject_pattern ".github/actions/deploy-over-ssh/action.yml" "docker compose down" "destructive compose down"

require_pattern "docker/docker-compose.yml" "sportchain-explorer:" "Atleta compose service"
require_pattern "docker/docker-compose.yml" "container_name: sportchain-explorer" "Atleta container name"
require_pattern "docker/docker-compose.yml" "atleta:" "Atleta external docker network"
require_pattern "docker/docker-compose.yml" "external: true" "external docker network"
require_pattern "docker/docker-compose.yml" "healthcheck:" "container healthcheck"
require_pattern "docker/docker-compose.yml" "com\\.atleta\\.role: \"polkadot-js-apps\"" "Atleta role label"
require_pattern "docker/docker-compose.yml" "com\\.atleta\\.service: \"sportchain-explorer\"" "Atleta service label"

require_pattern "docker/Dockerfile" "ENV WS_URL=" "runtime WS_URL support"
require_pattern "docker/Dockerfile" "STOPSIGNAL SIGQUIT" "nginx graceful stop signal"
require_pattern "docker/Dockerfile" "env\\.sh && exec /docker-entrypoint\\.sh nginx -g 'daemon off;'" "runtime env rendering"
require_pattern "docker/nginx/nginx.conf" "Content-Security-Policy" "frame protection header"

require_pattern "packages/apps-config/src/endpoints/testing.ts" "info: 'Atleta'" "Atleta endpoint entries"
require_pattern "packages/apps-config/src/endpoints/testing.ts" "wss://rpc\\.mainnet\\.atleta\\.network" "Atleta mainnet RPC"
require_pattern "packages/apps-config/src/endpoints/testing.ts" "wss://rpc\\.testnet-v2\\.atleta\\.network" "Atleta testnet-v2 RPC"
require_pattern "packages/apps-config/src/settings/ethereumChains.ts" "'atleta'" "Atleta EVM chain setting"
require_pattern "packages/apps-config/src/api/typesBundle.ts" "\"atleta\"" "Atleta type bundle"

echo "Atleta customization guard passed."
