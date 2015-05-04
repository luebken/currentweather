# Your first application with Node.JS, Docker, Redis on Giant Swarm

This is a simple example to write Node.JS applications and deploy them on [Giant Swarm]((https://giantswarm.io/)). It queries an external API and caches the data in an Redis cache.

Check out the full tutorial:

http://docs.giantswarm.io/guides/your-first-application/nodejs/

## Prerequisites

* Have a Giant Swarm account and the [swarm cli](http://docs.giantswarm.io/installation/gettingstarted/#installing-the-cli) running. [Request a free invite](https://giantswarm.io/).
* Have [Docker](https://docs.docker.com/installation/) running and be familiar with the basic Docker commands and Makefiles.

## Edit source

The application is implemented in [server.js](server.js). It starts a webserver and on root request queries the [openweather API](http://api.openweathermap.org/data/2.5/weather?q=Cologne) caches the result in Redis and extracts and returns the current weather for Cologne.

## Run locally

To run the two required containers locally you just have to do

```
$ make docker-build
$ make docker-run-redis
$ make docker-run
```

This creates a custom Docker image with the Node.JS sources and starts both the custom Docker container and a Redis container.

To test it on a Mac run something like: `curl $(boot2docker ip):1337` on Linux machines `curl localhost:1337` should be sufficient.

## Run in on Giant Swarm
To deploy it on Giant Swarm you just have to do a `make swarm-up`. This:
* builds appropriate Docker images
* uploads them to the Giant Swarm registry
* uploads the `swarm.json` and starts the application.

To test it run something like: `curl currentweather-YOURUSERNAME.gigantic.io` and replace YOURUSERNAME with your Giant Swarm username.

For all build and deploy details see the [Makefile](Makefile).

For further documentation and guides see the [docs](http://docs.giantswarm.io/).

## In other languages

* [Golang](https://github.com/giantswarm/giantswarm-firstapp-go)
* [Ruby](https://github.com/giantswarm/giantswarm-firstapp-ruby)
* [Python](https://github.com/giantswarm/giantswarm-firstapp-python)
* [PHP](https://github.com/giantswarm/giantswarm-firstapp-php)
* [Java](https://github.com/giantswarm/giantswarm-firstapp-java)
