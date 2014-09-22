build:
	docker build -t luebken/currentweather .
	docker pull redis
run: build
	docker pull redis
	docker run -d --name redis redis
	docker run  -i -p 1337:1337 --link redis:redis luebken/currentweather
push: build
	docker push luebken/currentweather