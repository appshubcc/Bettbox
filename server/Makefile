build:
	go build -v -o bin/server ./server

run: build
	./bin/server

docker-build:
	docker build -t bettboxt-server:latest -f server/Dockerfile .

docker-run:
	docker run --rm -p 8080:8080 bettboxt-server:latest
