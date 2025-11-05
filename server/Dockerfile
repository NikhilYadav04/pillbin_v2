FROM node:20.13.1-slim

ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 5000

CMD [ "node", "server.js" ]