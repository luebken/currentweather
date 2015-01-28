PROJECT = currentweather
REGISTRY = registry.giantswarm.io
USERNAME :=  $(shell swarm user)

docker-build:
	docker pull redis
	docker build -t $(REGISTRY)/$(USERNAME)/$(PROJECT) .

docker-run-redis:
	docker run --name=redis -d redis

docker-run:
	docker run --link redis:redis -p 1337:1337 -ti --rm $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-push: docker-build
	docker push $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-pull:
	docker pull $(REGISTRY)/$(USERNAME)/$(PROJECT)

swarm-up: docker-push
	swarm up swarm.json --var=username=$(USERNAME)