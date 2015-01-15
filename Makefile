PROJECT = sparkexample
REGISTRY = registry.giantswarm.io
# The default company equeals to your username
COMPANY :=  $(shell swarm user)

build:
	docker build -t $(REGISTRY)/$(COMPANY)/$(PROJECT) .

run-redis:
	docker run --name="redis" -p 6379:6379 -d redis

run:
	docker run --link redis:redis -p 1337:1337 -ti --rm $(REGISTRY)/$(COMPANY)/$(PROJECT)

push:
	docker push $(REGISTRY)/$(COMPANY)/$(PROJECT)

pull:
	docker pull $(REGISTRY)/$(COMPANY)/$(PROJECT)

deploy:
	swarm up swarm.json --var=company=$(COMPANY)
