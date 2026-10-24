# CI/CD and Upstream Sync

This fork deploys the `atleta` branch as the Atleta-hosted Polkadot JS Apps
image. The upstream source is `polkadot-js/apps`.

## Environment

There is a single environment, `prod`:

- host: `134.195.199.82`, compose directory `/opt/polkadot-explorer`;
- container / compose service: `sportchain-explorer`;
- URL: https://polkadot-explorer.atleta.network

## Branches

- `atleta` is the Atleta integration and deployment branch.
- Upstream release syncs must be done through `Sync upstream release`.
- Sync branches use `sync/upstream-<release_tag>` unless overridden manually.

## Toolchain

- Builder image: `node:24.22.1-bookworm-slim` (matches `.nvmrc`), yarn
  `4.6.0` via corepack (`packageManager`), `yarn install --immutable`.
- Runtime image: `nginx:1.31.8-alpine3.24-slim`.

## Workflows

- `CI config validation` validates workflow/action YAML, scripts, Atleta
  customization guards, and Docker Compose.
- `Build and release Docker image` builds and pushes the `prod` image on every
  push to `atleta` (tags `<sha>` and `latest`); it can also be run manually via
  `workflow_dispatch` (optionally with `sha`). It never deploys.
- `Deploy service` deploys an already-built image to `prod` over SSH. It is
  `workflow_dispatch`-only and requires `confirm_prod=DEPLOY_PROD`.
- `Sync upstream release` merges an upstream release tag into a separate branch,
  validates Atleta invariants, and opens or updates a PR into `atleta`.

Production deployment is manual-only through `Deploy service` with
`confirm_prod=DEPLOY_PROD`. Deploy is intentionally not triggered on push,
because `Sync upstream release` lands upstream releases into `atleta` and those
should be reviewed before rollout.

```sh
gh workflow run deploy_service.yml --ref atleta \
  -f service=polkadot-js-apps -f environment=prod \
  -f sha=<commit-sha> -f confirm_prod=DEPLOY_PROD
```

Rollback is the same command with an older, already-built `sha`.

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
```

## Repository Secrets

Required repository secrets:

```text
CI_REGISTRY
CI_REGISTRY_REPO
CI_REGISTRY_USER
CI_REGISTRY_PASSWORD
```

## Environment Secrets

The `prod` GitHub environment needs:

```text
BASE_PATH
HOST_1
HOST_1_USERNAME
SSH_PRIVATE_KEY
```

`Deploy service` fails early with a clear error if any of them is missing.

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
