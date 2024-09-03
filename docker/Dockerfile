FROM ubuntu:latest as builder

# Install any needed packages
RUN apt-get update && \
  apt-get install --no-install-recommends -y build-essential curl git gnupg ca-certificates

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install --no-install-recommends -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN npm install yarn -g

WORKDIR /apps
COPY . .

RUN yarn && NODE_ENV=production yarn build:www

# ===========================================================
FROM nginx:stable-alpine

# The following is mainly for doc purpose to show which ENV is supported
ENV WS_URL=

WORKDIR /usr/share/nginx/html

COPY docker/nginx-container/env.sh .

RUN apk add --no-cache bash; chmod +x env.sh

COPY docker/nginx /etc/nginx
COPY --from=builder /apps/packages/apps/build /usr/share/nginx/html

COPY docker/nginx-container/check_ssl.sh /

ENTRYPOINT ["/bin/bash", "-c"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["/check_ssl.sh & /usr/share/nginx/html/env.sh && exec /docker-entrypoint.sh nginx -g 'daemon off;'"]
