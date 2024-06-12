# Building from source
FROM node:lts-alpine3.18 AS build-step
ARG DYNAMIC_CONFIG=true
ARG historyMode="history"
ARG pathPrefix

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

RUN \[ "${DYNAMIC_CONFIG}" == "true" \] && sed -i "s|<!-- <script defer=\"defer\" src=\"/config.js\"></script> -->|<script defer=\"defer\" src=\"${pathPrefix}config.js\"></script>|g" public/index.html

# RUN npm run build -- --historyMode="${historyMode}" --pathPrefix="${pathPrefix}"

RUN npm run build -- --useTileLayerAsFallback=false --pathPrefix="/stac-browser/" --catalogUrl="https://datacube-stage.services.geo.ca/stac/api/" --tileSourceTemplate="https://titiler.datacube.services.geo.ca/cog/tiles/{z}/{x}/{y}?url={url}"

# Trying to us the actual container to build / will not work
FROM ghcr.io/radiantearth/stac-browser:latest
npm run build -- --useTileLayerAsFallback=false --pathPrefix="/stac-browser/" --catalogUrl="https://datacube-stage.services.geo.ca/api/" --tileSourceTemplate="https://titiler.datacube.services.geo.ca/cog/tiles/{z}/{x}/{y}?url={url}"
aws s3 sync --delete dist/ s3://fgp-datacube-stage-templates/aws-datacube/web-server-files/internal-web-presence/stac-browser-int/

