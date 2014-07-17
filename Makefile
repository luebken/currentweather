build:
	docker build -t luebken/currentweather .
run:
	docker run -p 1337:1337 luebken/currentweather