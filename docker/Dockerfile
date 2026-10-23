FROM node:24.22.1-bookworm-slim AS builder

# Toolchain for native modules (node-gyp fallback when no prebuild is available)
RUN apt-get update && \
  apt-get install --no-install-recommends -y build-essential python3 git ca-certificates && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Use the yarn version pinned in package.json (packageManager) via corepack
RUN corepack enable

WORKDIR /apps
COPY . .

RUN yarn install --immutable && NODE_ENV=production yarn build:www

# ===========================================================
FROM nginx:1.31.8-alpine3.24-slim

# The following is mainly for doc purpose to show which ENV is supported
ENV WS_URL=

WORKDIR /usr/share/nginx/html

COPY docker/nginx-container/env.sh .

RUN apk add --no-cache bash; chmod +x env.sh

COPY docker/nginx /etc/nginx
COPY --from=builder /apps/packages/apps/build /usr/share/nginx/html

ENTRYPOINT ["/bin/bash", "-c"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["/usr/share/nginx/html/env.sh && exec /docker-entrypoint.sh nginx -g 'daemon off;'"]
