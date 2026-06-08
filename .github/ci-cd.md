# CI/CD and Upstream Sync

This fork deploys the `atleta` branch as the Atleta-hosted Polkadot JS Apps
image. The upstream source is `polkadot-js/apps`, branch `master`.

## Remotes

Local clones should keep both remotes:

```bash
git remote add upstream git@github.com:polkadot-js/apps.git
git fetch --all --prune --tags
```

Use `atleta` for Atleta-specific changes. Use the `Sync upstream` workflow to
merge `polkadot-js/apps:master` into a PR branch targeting `atleta`.

## Workflows

- `CI config validation` validates workflow/action YAML and Docker Compose on
  PRs and pushes to `atleta`.
- `Build and release Docker image` builds and pushes the Docker image.
- `Deploy service` deploys an already-built image over SSH.
- `Sync upstream` creates or updates a PR from
  `devops/sync-upstream-master` into `atleta`.

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
secrets. Manual dev deployment can also be triggered by running
`Build and release Docker image` with `deploy_after_build=true`.

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

The current `prod` environment has these deploy secrets. The `dev` environment
must receive its own values before automatic dev rollout can succeed.
