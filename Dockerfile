#https://github.com/dockerfile/nodejs/blob/master/Dockerfile
FROM dockerfile/nodejs

#Dont want to rely on VOLUME
WORKDIR /root

ADD package.json /root/

RUN npm install

ADD server.js /root/

EXPOSE 1337

CMD ["/usr/local/bin/node", "server.js"]