/* global server */
/* global client */
var http = require("http");
var redis = require("redis");
var url = require("url");

var redisAddress = "redis", // This is service discovery by DNS, and the name
  redisPort = 6379,         // is set by using REDIS_SERVICE_NAME while
  httpAddress = "0.0.0.0",  // doing `oc new-app` or via `docker --link`
  httpPort = "1337",        // or ...
  openWeatherMapApiKey = process.env.OPENWEATHERMAP_APIKEY;

if (openWeatherMapApiKey == "" ) {
  console.log("Missing mandatory env OPENWEATHERMAP_APIKEY");
  process.exit(1);
}

client = redis.createClient(redisPort, redisAddress);
client.on("error", function (err) {
  console.log("Catching error from Redis client to enable reconnect.");
  console.log(err);
});

server = http.createServer(function (request, response) {
  uurl = request.url.match(/^\/status\/(.+)/)
  var query
  if(uurl != null && uurl[1] != null) {
    query = uurl[1]
  } else {
    console.log("Didn't find query for request ", request.url)
    response.writeHead(404);
    response.end("Wrong query try /status/Bonn,DE");
  }

  client.get("currentweather-" + query, function (err, weatherObjectString) {
    if (weatherObjectString == null) {
      console.log(Date.now() + " Querying live weather data for ", query);
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
            weatherObject.owm_id = weather.weather[0].id;
            weatherObject.description = weather.weather[0].description;
            weatherObject.temperature = Math.round(weather.main.temp - 273);
            weatherObject.wind = Math.round(weather.wind.speed * 3.6);
          } catch (error) {
            console.log("Error during json parse: ", error);
            weatherObject.error = error
          }
          client.set("currentweather-" + query, JSON.stringify(weatherObject));
          client.expire("currentweather-" + query, 10);
          writeResponse(response, JSON.stringify(weatherObject));
        });
      }).on("error", function(e) {
        console.log("Got error: ", e);
      });
    } else {
      console.log("Using cached weather data", weatherObjectString);
      writeResponse(response, weatherObjectString);
    }
  });
})

server.listen(httpPort, httpAddress);

process.on('SIGTERM', function () {
  console.log("Received SIGTERM. Exiting.")
  server.close(function () {
    process.exit(0);
  });
});

function writeResponse(res, weather) {
  res.writeHead(200, {"Content-Type": "application/json",
                      "Access-Control-Allow-Origin": "*",
                      "Access-Control-Allow-Headers": "Content-Type",
                      'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'});
  res.end(weather);
}

console.log("Server running at 0.0.0.0:" + httpPort + "/");
