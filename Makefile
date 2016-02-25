DOCKER_USERNAME := luebken
OPENWEATHERMAP_APIKEY := 182564eaf55f709a58a13c40086fb5bb

# Building your custom docker image
docker-build:
	docker build -t $(DOCKER_USERNAME)/currentweather-nodejs .
	docker network create currentweather_nw || true

# Show which environment variables are avaiable
docker-show-available-envs:
	docker inspect -f "{{.Config.Labels }}" $(DOCKER_USERNAME)/currentweather-nodejs | sed "s/^map\[available-envs://" | sed "s/\]//" | jq .

# Starting redis container to run in the background
docker-run-redis:
	docker kill redis-container || true
	docker rm redis-container || true
	docker run -d --net=currentweather_nw --name redis-container redis

# Running your custom-built docker image locally
docker-run-currentweather:
	docker run --net=currentweather_nw --link=redis-container:redis -p 1337:1337 --rm -ti \
		-e OPENWEATHERMAP_APIKEY=$(OPENWEATHERMAP_APIKEY) \
		$(DOCKER_USERNAME)/currentweather-nodejs

# Pushing the freshly built image to the registry
docker-push:
	docker push $(DOCKER_USERNAME)/currentweather-nodejs

# To remove the stuff we built locally afterwards
docker-clean:
	docker kill redis-container
	docker rmi -f $(DOCKER_USERNAME)/currentweather-nodejs || true
	docker network rm currentweather_nw || true

kube-create:
	kubectl create -f redis-rc.yml
	kubectl create -f redis-svc.yml
	kubectl create -f currentweather-rc.yml
	kubectl create -f currentweather-svc.yml

kube-clean:
	kubectl delete rc/redis || true
	kubectl delete svc/redis || true
	kubectl delete rc/currentweather || true
	kubectl delete svc/currentweather || true