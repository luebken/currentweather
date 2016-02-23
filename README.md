Currentweather 
====================

A sample application for using NodeJS and Redis with Docker et al. It pings an external API and caches the data in an Redis cache.

## Locally with Docker

### Prerequisites

* Have Kubernetes & Docker running.

### JavaScript Code

The service is implemented in the file [server.js](server.js). it basically creates a webserver and on root request queries the [openweather API](http://api.openweathermap.org/data/2.5/weather?q=Cologne) caches the result in Redis and extracts and returns the current weather for Cologne.

## Testing the service locally

To run the two required containers locally you just have to do

```
$ make docker-build
$ make docker-run-redis
$ make docker-run
```

This creates a custom Docker image with the Node.JS sources and starts both the custom Docker container and a Redis container.

To test it run something like `curl localhost:1337`.

## On Giant Swarm

See the [downstream repository](https://github.com/giantswarm/giantswarm-currentweather
) for a detailed description on how to get this running on Giant Swarm.
