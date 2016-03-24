FROM node:0.10-slim
MAINTAINER matthias.luebken@gmail.com
WORKDIR /app

# install dependencies
ADD package.json /app/
RUN npm install

# install app
ADD server.js /app/

# Describe container dependencies
LABEL api.LINKS.redis=""\
      api.LINKS.redis.image="redis:latest"\
      api.LINKS.redis.port="6379"\
      api.LINKS.redis.description="For caching requests to OWM API."\
      api.LINKS.redis.mandatory="true"

# Set and describe available ENVs
ENV OPENWEATHERMAP_APIKEY=182564eaf55f709a58a13c40086fb5bb
LABEL api.ENV.OPENWEATHERMAP_APIKEY="" \
      api.ENV.OPENWEATHERMAP_APIKEY.description="Access key for OpenWeatherMap. See http://openweathermap.org/appid for details." \
      api.ENV.OPENWEATHERMAP_APIKEY.mandatory="false"

# Expose and describe available ports
EXPOSE 1337
LABEL api.EXPOSE.1337="" \
      api.EXPOSE.1337.protocol="http" \
      api.EXPOSE.1337.description="The main endpoint of this service."

ENTRYPOINT ["node", "server.js"]