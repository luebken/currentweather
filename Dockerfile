FROM node:0.10-slim

WORKDIR /app

# install dependencies
ADD package.json /app/

# install dependencies
RUN npm install

# install app
ADD server.js /app/

EXPOSE 1337
ENTRYPOINT ["node", "server.js"]
