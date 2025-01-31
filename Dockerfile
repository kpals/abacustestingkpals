ARG NODE_VERSION=lts
# multi-stage build

# depender - get production dependencies
FROM node:${NODE_VERSION} as depender
WORKDIR /build/
COPY package-lock.json package.json ./
RUN npm ci

# builder - create-react-app build
FROM depender as builder
WORKDIR /build/
COPY public/ public/
COPY src/ src/
COPY tests/ tests/
COPY tsconfig.json/ .
COPY craco.config.js/ .
RUN npm run build

# server - nginx alpine
FROM nginx:stable-alpine as server
COPY --from=builder /build/build /usr/share/nginx/html
COPY nginx-default.conf /etc/nginx/templates/default.conf.template
ENV KEYCLOAK_HOST "http://localhost/keycloak/auth"
ENV KEYCLOAK_CLIENT_ID ""
ENV KEYCLOAK_REALMS "tdf"
ENV ATTRIBUTES_HOST "http://localhost/attributes"
ENV ENTITLEMENTS_HOST "http://localhost/entitlements"
ENV KAS_HOST "http://localhost:8000"
ENV SERVER_BASE_PATH ""

EXPOSE 80
