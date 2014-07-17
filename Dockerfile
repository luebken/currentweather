#https://github.com/dockerfile/nodejs/blob/master/Dockerfile
FROM dockerfile/nodejs

#Dont want to rely on VOLUME
WORKDIR /root

ADD server.js /root/

EXPOSE 1337

CMD ["/usr/local/bin/node", "server.js"]