FROM node:0.10-slim

WORKDIR /app

# install dependencies
ADD package.json /app/
RUN npm install

# install app
ADD server.js /app/

# Describe which ENVs are available
LABEL com.example.available-envs "[\
{\"key\":\"OPENWEATHERMAP_APIKEY\",\
\"description\":\"APIKEY to access the OpenWeatherMap. Get one at http://openweathermap.org/appid\",\
\"mandatory\":true}\
]"

EXPOSE 1337
ENTRYPOINT ["node", "server.js"]
