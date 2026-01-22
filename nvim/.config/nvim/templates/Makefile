.DEFAULT_GOAL := up

basic: #basic environment components
	docker-compose up postgres keycloak redis nats nats-box smtp4dev filebrowser -d

superset-init:
	docker-compose up superset-init -d

superset-up: #after the superset-init
	docker-compose up superset-worker-beat superset-worker superset-app hello-data-superset-sidecar -d

down: #stop all containers
	docker-compose down

up: basic superset-init superset-up

help: ## Show all Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
