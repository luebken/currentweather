# Variable for re-use in the file
GIANTSWARM_USERNAME := $(shell swarm user)


# Building your custom docker image
docker-build:
	docker build -t registry.giantswarm.io/$(GIANTSWARM_USERNAME)/currentweather-nodejs .

# Starting redis container to run in the background
docker-run-redis:
	@docker kill currentweather-redis-container > /dev/null || true
	@docker rm currentweather-redis-container > /dev/null || true
	docker run -d --name currentweather-redis-container redis

# Running your custom-built docker image locally
docker-run:
	docker run --link currentweather-redis-container:redis -p 1337:1337 --rm -ti \
		--name currentweather-nodejs-container \
		registry.giantswarm.io/$(GIANTSWARM_USERNAME)/currentweather-nodejs

# Pushing the freshly built image to the registry
docker-push:
	docker push registry.giantswarm.io/$(GIANTSWARM_USERNAME)/currentweather-nodejs

# Starting your service on Giant Swarm.
# Requires prior pushing to the registry ('make docker-push')
swarm-up:
	swarm up

# Removing your service again from Giant Swarm
# to free resources. Also required before changing
# the swarm.json file and re-issueing 'swarm up'
swarm-delete:
	swarm delete

# To remove the stuff we built locally afterwards
clean:
	docker rmi -f registry.giantswarm.io/$(GIANTSWARM_USERNAME)/currentweather-nodejs
