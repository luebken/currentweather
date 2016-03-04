FROM node:0.10-slim

MAINTAINER matthias.luebken@gmail.com

WORKDIR /app

# install dependencies
ADD package.json /app/
RUN npm install

# install app
ADD server.js /app/

# Describe which ENVs are available
# LABEL api.expected-envs "[\
# {\"key\":\"OPENWEATHERMAP_APIKEY\",\
# \"description\":\"APIKEY to access the OpenWeatherMap. Get one at http://openweathermap.org/appid\",\
# \"mandatory\":true}\
# ]"

LABEL api.expected-envs.OPENWEATHERMAP_APIKEY=""\
      api.expected-envs.OPENWEATHERMAP_APIKEY.description="APIKEY to access the OpenWeatherMap. Get one at http://openweathermap.org/appid " \
      api.expected-envs.OPENWEATHERMAP_APIKEY.mandatory="true"

# LABEL api.expected-args "[\
# {\"arg\":\"-q QUERY\",\
# \"description\":\"The query for openweathermap.\",\
# \"default\":\"Cologne, DE\",\
# \"mandatory\":false}\
# ]"
# 
# LABEL api.expected-links "[\
# {\"name\":\"redis:latest\",\
# \"port\":\"1337\",\
# \"description\":\"Needed for requests caching\",\
# \"mandatory\":true}\
# ]"

EXPOSE 1337
ENTRYPOINT ["node", "server.js"]
