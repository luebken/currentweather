Currentweather 1.0.0 
====================

A sample application for using NodeJS and Redis with Docker et al. It pings an external API and caches the data in an Redis cache.

## Versioning

We use a [semantic versioning](http://semver.org/spec/v2.0.0.html)

### Prerequisites

* Have Kubernetes & Docker running.

### JavaScript Code

The service is implemented in the file [server.js](server.js). it basically creates a webserver and on root request queries the [openweather API](http://api.openweathermap.org/data/2.5/weather?q=Cologne) caches the result in Redis and extracts and returns the current weather for Cologne.

### Testing the service locally with Docker

To run the two required containers locally you just have to do

```
$ make docker-build
$ make docker-run-redis
$ make docker-run
```

This creates a custom Docker image with the Node.JS sources and starts both the custom Docker container and a Redis container.

To test it run something like `curl localhost:1337`.

### Testing the service locally with Kubernetes

```
$ make docker-build
$ make docker-push
$ make kube-create
```

This uses [NodePorts](http://kubernetes.io/v1.0/docs/user-guide/services.html#type-nodeport) which you should see in the out put (e.g. tcp:32476).

If you have added a rule to Virtualbox etc you can test it and run something like `curl localhost:32476`.


## On Giant Swarm

See the [downstream repository](https://github.com/giantswarm/giantswarm-currentweather
) for a detailed description on how to get this running on Giant Swarm.

