build:
	docker build -t luebken/currentweather .
run: build
	docker run  -i -p 1337:1337 --name weather luebken/currentweather