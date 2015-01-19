PROJECT = currentweather
REGISTRY = registry.giantswarm.io
# The default company equals to your username
COMPANY :=  $(shell swarm user)

build:
	docker build -t $(REGISTRY)/$(COMPANY)/$(PROJECT) .

run-local-redis:
	docker run --name=redis -d redis

run-local-nodejs:
	docker run --link redis:redis -p 1337:1337 -ti --rm $(REGISTRY)/$(COMPANY)/$(PROJECT)

push:
	docker push $(REGISTRY)/$(COMPANY)/$(PROJECT)

pull:
	docker pull $(REGISTRY)/$(COMPANY)/$(PROJECT)

deploy:
	swarm up swarm.json --var=company=$(COMPANY)
