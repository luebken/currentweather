var http = require("http");
var redis = require("redis");

var redisAddress = process.env.REDIS_PORT_6379_TCP_ADDR,
  redisPort = process.env.REDIS_PORT_6379_TCP_PORT,
  httpAddress = "0.0.0.0",
  httpPort = "1337";

client = redis.createClient(redisPort, redisAddress);

server = http.createServer(function (request, response) {
  client.get("currentweather", function (err, weatherString) {
    if (weatherString == null) {
      console.log("MDL Querying live weather data");
      var url = "http://api.openweathermap.org/data/2.5/weather?q=Cologne";
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

console.log("Server running at http://<ip-address>:" + httpPort + "/");
