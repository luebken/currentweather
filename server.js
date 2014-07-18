var http = require('http');
var redis = require('redis');

var addr = process.env.REDIS_PORT_6379_TCP_ADDR;
var port = process.env.REDIS_PORT_6379_TCP_PORT;

client = redis.createClient(port, addr);

http.createServer(function (req, res) {
  client.get("currentweather", function (err, weather) {
    if(weather == null) {
      console.log('querying live weather data');
      var url = "http://api.openweathermap.org/data/2.5/weather?q=Cologne";
      http.get(url, function(res2) {
        var body = '';
        res2.on('data', function(chunk) {
          body += chunk;
        });
        res2.on('end', function() {
          var weatherjson = JSON.parse(body);
          var weather_new = weatherjson.weather[0].description;
          client.set('currentweather', weather_new);
          client.expire('currentweather', 60);
          writeResponse(res, weather_new);
        });
      }).on('error', function(e) {
        console.log("Got error: ", e);
      });
    } else {
      console.log('using cached weather data');
      writeResponse(res, weather);
    }
  })
}).listen(1337, '0.0.0.0');

function writeResponse(res, weather) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World from Cologne: ' + weather + '\n');
}

console.log('Server running at http://0.0.0.0:1337/');