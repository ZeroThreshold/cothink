FROM node:18 as base

# Create app directory
RUN mkdir -p /opt/app
WORKDIR /opt/app

# Install app dependencies
COPY ./package.json package-lock.json ./
RUN npm ci

# Bundle frontend
COPY src ./src
COPY assets ./assets
COPY config ./config
RUN npm run build

FROM node:18-alpine
ENV NODE_ENV=prod

# Create app directory
RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY ./package.json ./package-lock.json config.default.yml ./
RUN npm ci --only=prod --save-dev webpack-dev-server

COPY scripts ./scripts
COPY --from=base /opt/app/dist ./dist

EXPOSE 8080
ENTRYPOINT ["npm", "run", "start"]