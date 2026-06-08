# CI/CD and Upstream Sync

This fork deploys the `atleta` branch as the Atleta-hosted Polkadot JS Apps
image. The upstream source is `polkadot-js/apps`.

## Branches

- `atleta` is the Atleta integration and deployment branch.
- Upstream release syncs must be done through `Sync upstream release`.
- Sync branches use `sync/upstream-<release_tag>` unless overridden manually.

## Workflows

- `CI config validation` validates workflow/action YAML, scripts, Atleta
  customization guards, and Docker Compose.
- `Build and release Docker image` builds and pushes the Docker image.
- `Deploy service` deploys an already-built image over SSH.
- `Sync upstream release` merges an upstream release tag into a separate branch,
  validates Atleta invariants, and opens or updates a PR into `atleta`.

Production deployment is manual-only through `Deploy service` with
`confirm_prod=DEPLOY_PROD`.

## Repository Variables

Required repository variables:

```text
SERVICE_NAME=sportchain-explorer
DOCKER_COMPOSE_FILE=docker-compose.yml
```

Optional repository variables:

```text
COMPOSE_SERVICE_NAME=sportchain-explorer
CONTAINER_NAME=sportchain-explorer
AUTO_DEPLOY_DEV=false
```

Set `AUTO_DEPLOY_DEV=true` only after the `dev` environment has SSH deploy
secrets. With the current settings, pushes to `atleta` build the dev image but
do not auto-deploy it.

## Repository Secrets

Required repository secrets:

```text
CI_REGISTRY
CI_REGISTRY_REPO
CI_REGISTRY_USER
CI_REGISTRY_PASSWORD
```

## Environment Secrets

Each deployable GitHub environment (`dev`, `prod`) needs:

```text
BASE_PATH
HOST_1
HOST_1_USERNAME
SSH_PRIVATE_KEY
```

The current `prod` environment has deploy secrets. The `dev` environment does
not currently have deploy secrets, so automatic dev rollout must stay disabled
until those values are added.

## Upstream Release Sync

Run `Sync upstream release` with:

```text
release_tag=v0.x.y
upstream_repo=polkadot-js/apps
target_branch=atleta
auto_merge=false
```

The workflow:

- fetches the upstream release tag;
- creates a sync branch from `atleta`;
- merges the tag into that branch;
- fails early and lists files if conflicts occur;
- validates Atleta RPC endpoints, CI/CD behavior, Docker Compose labels and
  healthchecks, and secret patterns;
- opens or updates a PR into `atleta`.
