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

docker-labels: ## Show labels of the image
	docker inspect $(DOCKER_USERNAME)/currentweather-nodejs | jq .[].Config.Labels

docker-run-redis: docker-create-network ## Starting redis container to run in the background
	docker kill redis || true
	docker rm redis || true
	docker run -d --net=currentweather_nw --name redis redis

docker-run-currentweather: docker-build-currentweather docker-run-redis ## Running your custom-built docker image locally
	docker run --net=currentweather_nw -p 1337:1337 --rm -ti \
		-e OPENWEATHERMAP_APIKEY=$(OPENWEATHERMAP_APIKEY) \
		$(DOCKER_USERNAME)/currentweather-nodejs

docker-push: docker-build-currentweather ## Pushing the freshly built image to the registry
	docker push $(DOCKER_USERNAME)/currentweather-nodejs

docker-stop: ## Remove the stuff we built locally afterwards
	docker kill redis ; docker rm redis || true
	docker rmi -f $(DOCKER_USERNAME)/currentweather-nodejs || true
	docker network rm currentweather_nw || true

kube-create: ## Create kubernetes rc and svc
	kubectl create -f kubernetes/redis-rc.yml
	kubectl create -f kubernetes/redis-svc.yml
	kubectl create -f kubernetes/currentweather-cm.yml
	kubectl create -f kubernetes/currentweather-rc.yml
	kubectl create -f kubernetes/currentweather-svc.yml

kube-delete: ## Delete rc, cm and svc
	kubectl scale --replicas=0 rc redis
	kubectl delete replicationcontroller redis
	kubectl delete service redis
	kubectl scale --replicas=0 rc currentweather
	kubectl delete configmap currentweather
	kubectl delete replicationcontroller currentweather
	kubectl delete service currentweather

test:
	curl localhost:1337/status/Bonn,DE

# via http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
