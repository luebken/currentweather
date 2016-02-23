DOCKER_USERNAME := luebken


# Building your custom docker image
docker-build:
	docker build -t $(DOCKER_USERNAME)/currentweather-nodejs .

# Starting redis container to run in the background
docker-run-redis:
	@docker kill currentweather-redis-container > /dev/null || true
	@docker rm currentweather-redis-container > /dev/null || true
	docker run -d --name currentweather-redis-container redis

# Running your custom-built docker image locally
docker-run:
	docker run --link currentweather-redis-container:redis -p 1337:1337 --rm -ti \
		--name currentweather-nodejs-container \
		$(DOCKER_USERNAME)/currentweather-nodejs

# Pushing the freshly built image to the registry
docker-push:
	docker push /$(DOCKER_USERNAME)/currentweather-nodejs

# To remove the stuff we built locally afterwards
clean:
	docker rmi -f $(DOCKER_USERNAME)/currentweather-nodejs
