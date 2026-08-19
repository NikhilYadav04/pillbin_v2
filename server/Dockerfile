# firebase-admin@14 declares engines node >=22 — Node 20 loads the messaging
# entrypoint but crashes on anything that pulls firebase-admin/auth
FROM node:22-alpine

WORKDIR /app

# Copied first so a source-only change does not reinstall dependencies
COPY package.json package-lock.json ./

# ci installs exactly what the lockfile pins and fails loudly if the two drift
RUN npm ci --omit=dev

COPY . .

ENV NODE_ENV=production

# server.js listens on process.env.PORT || 5000; the platform sets PORT
EXPOSE 5000

CMD ["node", "server.js"]
