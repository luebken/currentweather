/* global server */
/* global client */
var http = require("http"),
  winston = require('winston'),
  redis = require("redis"),
  express = require('express'),
  cors = require('cors'),
  app = express();

var redisAddress = "redis", // This is service discovery by DNS, and the name
  redisPort = 6379,         // is set by using REDIS_SERVICE_NAME while
  httpAddress = "0.0.0.0",  // doing `oc new-app` or via `docker --link`
  httpPort = "1337",        // or ...
  openWeatherMapApiKey = process.env.OPENWEATHERMAP_APIKEY;

if (openWeatherMapApiKey == "" ) {
  winston.error("Missing mandatory env OPENWEATHERMAP_APIKEY");
  process.exit(1);
}

redis_client = redis.createClient(redisPort, redisAddress);
redis_client.on("error", function (err) {
  winston.warn("Catching error from Redis client to enable reconnect.");
  winston.error(err);
});

app.use(cors());

app.get('/status/:q', cors(), function (req, res, next) {
  var query = req.params.q
  winston.info(Date.now() + " some client requested weather data for ", query);

  redis_client.get("currentweather-" + query, function (err, weatherObjectString) {
    if (weatherObjectString == null) {
      winston.info(Date.now() + " Querying live weather data for ", query);
      var url = "http://api.openweathermap.org/data/2.5/weather?q=" + query + "&appid=" + openWeatherMapApiKey;

      http.get(url, function(apiResponse) {
        var body = "";
        apiResponse.on("data", function(chunk) {
          body += chunk;
        });

        apiResponse.on("end", function() {
          var weatherObject = {}
          weatherObject.location = query
          try {
            var weather = JSON.parse(body);
            weatherObject.description = weather.weather[0].description;
            weatherObject.temperature = Math.round(weather.main.temp - 273);
            weatherObject.wind = Math.round(weather.wind.speed * 3.6);
          } catch (error) {
            winston.error("Error during json parse: ", error);
            weatherObject.error = error
          }
          redis_client.set("currentweather-" + query, JSON.stringify(weatherObject));
          redis_client.expire("currentweather-" + query, 10);
          res.json(weatherObject);
        });
      }).on("error", function(e) {
        winston.error("Got error: ", e);
      });
    } else {
      winston.info("Using cached weather data", weatherObjectString);
      res.send(weatherObjectString);
    }
  });
});

app.get('/healthz', cors(), function (req, res, next) {
  var healthzObject = {}

  healthzObject.currentweather_api_version = 'v1';
  healthzObject.redis_version = redis_client.server_info.redis_version;

  // TODO if redis_client is not ready, we should not return 200
  res.json(healthzObject);
})

app.listen(httpPort, function () {
  winston.info("Server running at 0.0.0.0:" + httpPort + "/");
});

process.on('SIGTERM', function () {
  winston.info("Received SIGTERM. Exiting.")

  server.close(function () {
    process.exit(0);
  });
});
