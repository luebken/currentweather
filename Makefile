DOCKER_USERNAME := luebken
OPENWEATHERMAP_APIKEY := 182564eaf55f709a58a13c40086fb5bb

# run `make` to see options
.DEFAULT_GOAL := help

docker-build: ## Building your custom docker image
	docker build -t $(DOCKER_USERNAME)/currentweather-nodejs .
	docker network create currentweather_nw || true

docker-labels: ## Show labels of the image
	docker inspect $(DOCKER_USERNAME)/currentweather-nodejs | jq .[].Config.Labels

docker-run-redis: ## Starting redis container to run in the background
	docker kill redis-container || true
	docker rm redis-container || true
	docker run --detach --net=currentweather_nw --name redis-container redis-container

docker-run-currentweather: ## Running your custom-built docker image locally
	docker run --net=currentweather_nw --link=redis-container:redis-container --name currentweather-container -p 1337:1337 --rm -ti \
		-e OPENWEATHERMAP_APIKEY=$(OPENWEATHERMAP_APIKEY) \
		$(DOCKER_USERNAME)/currentweather-nodejs

docker-push: ## Pushing the freshly built image to the registry
	docker push $(DOCKER_USERNAME)/currentweather-nodejs

docker-stop: ## Remove the stuff we built locally afterwards
	docker kill redis-container
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

# via http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
