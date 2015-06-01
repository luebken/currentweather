FROM node

WORKDIR /app

# install dependencies
ADD package.json /app/
RUN npm install

# install app
ADD server.js /app/

EXPOSE 1337
ENTRYPOINT ["node", "server.js"]