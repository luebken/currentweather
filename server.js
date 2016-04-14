/* global server */
/* global client */
/* global httpdispatcher */
/* global util */
var http = require("http");
var redis = require("redis");
var dispatcher = require('httpdispatcher');
var util = require("util");

var redisAddress = "redis",
  redisPort = 6379,
  httpAddress = "0.0.0.0",
  httpPort = "1337",
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

server = http.createServer(function(request, response) {
  dispatcher.dispatch(request, response);
});

dispatcher.onError(function(request, response) {
		response.writeHead(404);
});

dispatcher.onGet("/", function(request, response) {
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
});

dispatcher.onGet("/status", function(request, response) {
  response.writeHead(200, {"Content-Type": "application/json"});
  response.end('{"null": 0, "data": ' + util.inspect(process.env, {showHidden: true, depth: null}) +
                ', "load": 0.0}'); // FIXME
});

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

console.log("Server running at 0.0.0.0:" + httpPort + "/");
