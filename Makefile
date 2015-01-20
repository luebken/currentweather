PROJECT = currentweather
REGISTRY = registry.giantswarm.io
USERNAME :=  $(shell swarm user)

build:
	docker build -t $(REGISTRY)/$(USERNAME)/$(PROJECT) .

run-local-redis:
	docker run --name=redis -d redis

run-local-nodejs:
	docker run --link redis:redis -p 1337:1337 -ti --rm $(REGISTRY)/$(USERNAME)/$(PROJECT)

push:
	docker push $(REGISTRY)/$(USERNAME)/$(PROJECT)

pull:
	docker pull $(REGISTRY)/$(USERNAME)/$(PROJECT)

deploy:
	swarm up swarm.json --var=username=$(USERNAME)
