var http = require('http');

http.createServer(function (req, res) {
  console.log('Request from: ', req.headers['x-real-ip'] + ", " + req.headers['user-agent']);
	var url = "http://api.openweathermap.org/data/2.5/weather?q=Cologne";
  console.log('Quering openweathermap.org');
	http.get(url, function(res2) {
    var body = '';
    res2.on('data', function(chunk) {
    	body += chunk;
    });
    res2.on('end', function() {
      var weatherjson = JSON.parse(body);
      var weather_desc = weatherjson.weather[0].description;
      console.log('Writing response:', weather_desc);
      res.writeHead(200, {'Content-Type': 'text/plain'});
  		res.end('Hello World from Cologne: ' + weather_desc + '\n');
    });
	}).on('error', function(e) {
		console.log("Got error: ", e);
	});
}).listen(1337, '0.0.0.0');
console.log('Server running at http://0.0.0.0:1337/');