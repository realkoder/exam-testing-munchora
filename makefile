.PHONY: dev
dev:
	docker-compose -f docker-compose.dev.mysql.yml up -d
	cd server && bin/rails s &
	cd client && npm run dev

.PHONY: stop
stop:
	docker-compose -f docker-compose.dev.mysql.yml down
	pkill -f "rails s"
	pkill -f "npm run dev"

.PHONY: build-docker
build-docker:
	docker build --platform linux/amd64 --build-arg VITE_ENV=production --build-arg VITE_BASE_URL=https://munchora.pro/api/v1 --build-arg VITE_BASE_URL_SSR=http://munchora-backend:9090/api/v1 -t ghcr.io/realkoder/munchora-client:latest ./client
	docker build --platform linux/amd64 -f server/Dockerfile.prod -t ghcr.io/realkoder/munchora-backend:latest ./server

.PHONY: push-docker
push-docker:
	docker push ghcr.io/realkoder/munchora-client:latest
	docker push ghcr.io/realkoder/munchora-backend:latest

