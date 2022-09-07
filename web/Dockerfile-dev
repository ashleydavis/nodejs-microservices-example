FROM node:18-alpine

WORKDIR /usr/src/app
COPY package*.json ./
COPY nodemon.json ./

CMD npm config set cache-min 9999999 \
    && npm install \
    && npm run start:dev