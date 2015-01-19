#https://registry.hub.docker.com/u/google/nodejs/
#https://github.com/GoogleCloudPlatform/nodejs-docker/blob/master/base/Dockerfile
FROM google/nodejs

WORKDIR /app

ADD package.json /app/
RUN npm install
ADD server.js /app/

EXPOSE 1337

CMD ["/nodejs/bin/node", "server.js"]
