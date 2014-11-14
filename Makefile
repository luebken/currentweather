PROJECT=currentweather
COMPANY=giantswarm
REGISTRY=registry.giantswarm.io

default: ;

build:
	docker build -t $(REGISTRY)/$(COMPANY)/$(PROJECT) .
	docker pull redis
	
run:
	docker run -d --name redis redis
	docker run  -i -p 1337:1337 --link redis:redis $(REGISTRY)/$(COMPANY)/$(PROJECT)