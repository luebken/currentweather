/* global server */
/* global client */
var http = require("http");
var redis = require("redis");

var redisAddress = "redis",
  redisPort = 6379,
  httpAddress = "0.0.0.0",
  httpPort = "1337",
  openWeatherMapApiKey = process.env.OPENWEATHERMAP_APIKEY || "182564eaf55f709a58a13c40086fb5bb";

client = redis.createClient(redisPort, redisAddress);
client.on("error", function (err) {
  console.log("Catching error from Redis client to enable reconnect.");
  console.log(err);
});

server = http.createServer(function (request, response) {
  client.get("currentweather", function (err, weatherString) {
    if (weatherString == null) {
      console.log("Querying live weather data");
      var url = "http://api.openweathermap.org/data/2.5/weather?q=Cologne,DE&appid=" + openWeatherMapApiKey;
      http.get(url, function(apiResponse) {
        var body = "";
        apiResponse.on("data", function(chunk) {
          body += chunk;
        });
        apiResponse.on("end", function() {
          var weather = JSON.parse(body);
          weatherString = weather.weather[0].description;
          weatherString += ", temperature " + Math.round(weather.main.temp - 273);
          weatherString += " degrees, wind " + Math.round(weather.wind.speed * 3.6) +  " km/h"
          client.set("currentweather", weatherString);
          client.expire("currentweather", 60);
          writeResponse(response, weatherString);
        });
      }).on("error", function(e) {
        console.log("Got error: ", e);
      });
    } else {
      console.log("Using cached weather data");
      writeResponse(response, weatherString);
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
  res.writeHead(200, {"Content-Type": "text/html"});
  res.end("Current weather in Cologne: " + weather + "\n");
}

console.log("Server running at 0.0.0.1:" + httpPort + "/");