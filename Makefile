DOCKER_USERNAME := luebken
OPENWEATHERMAP_APIKEY := 182564eaf55f709a58a13c40086fb5bb

# run `make` to see options
.DEFAULT_GOAL := help

docker-create-network:
	docker network create currentweather_nw || true

docker-delete-network:
	docker network rm currentweather_nw

docker-build-currentweather: ## Building your custom docker image
	docker build -t $(DOCKER_USERNAME)/currentweather-nodejs .

docker-build-ui:
	docker build -t $(DOCKER_USERNAME)/currentweather-ui -f Dockerfile-UI .

docker-labels: ## Show labels of the image
	docker inspect $(DOCKER_USERNAME)/currentweather-nodejs | jq .[].Config.Labels

docker-run-redis: docker-create-network ## Starting redis container to run in the background
	docker kill redis || true
	docker rm redis || true
	docker run -d --net=currentweather_nw --name redis redis

docker-run-ui: docker-build-ui ## Starting UI container to run in the background
	docker kill currentweather-ui || true
	docker rm currentweather-ui || true
	docker run -d --net=currentweather_nw --publish 8088:80 --name currentweather-ui $(DOCKER_USERNAME)/currentweather-ui

docker-run-currentweather: docker-build-currentweather docker-build-ui docker-run-redis docker-run-ui ## Running your custom-built docker image locally
	docker run --net=currentweather_nw -p 1337:1337 --rm -ti \
		-e OPENWEATHERMAP_APIKEY=$(OPENWEATHERMAP_APIKEY) \
		$(DOCKER_USERNAME)/currentweather-nodejs

docker-push: docker-build-currentweather ## Pushing the freshly built image to the registry
	docker push $(DOCKER_USERNAME)/currentweather-nodejs

docker-stop: ## Remove the stuff we built locally afterwards
	docker kill redis ; docker rm redis || true
	docker kill currentweather-ui ; docker rm currentweather-ui || true
	docker rmi -f $(DOCKER_USERNAME)/currentweather-ui || true
	docker rmi -f $(DOCKER_USERNAME)/currentweather-nodejs || true
	docker network rm currentweather_nw || true

kube-run: ## Create kubernetes rc and svc
	kubectl create -f redis-rc.yml
	kubectl create -f redis-svc.yml
	kubectl create -f currentweather-cm.yml
	kubectl create -f currentweather-rc.yml
	kubectl create -f currentweather-svc.yml

kube-stop: ## Delete rc, cm and svc
	kubectl scale --replicas=0 rc redis
	kubectl delete -f redis-rc.yml
	kubectl delete -f redis-svc.yml
	kubectl scale --replicas=0 rc currentweather
	kubectl delete -f currentweather-cm.yml
	kubectl delete -f currentweather-rc.yml
	kubectl delete -f currentweather-svc.yml

test:
	curl localhost:1337/status

# via http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
