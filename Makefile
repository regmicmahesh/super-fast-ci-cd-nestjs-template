SHELL := /bin/bash

.DEFAULT_GOAL := help

export APP_ROOT := $(shell 'pwd')

-include $(APP_ROOT)/Makefile.override

docker/up: ## Start containers
	@docker-compose up -d
	@docker-compose logs app --follow

docker/stop: ## Stop containers
	@docker-compose stop

docker/down: ## Stop and remove containers, networks, images, and volumes
	@docker-compose down

docker/build: ## Build docker images for development
	@docker-compose build

docker/config: ## Show docker-compose config
	@docker-compose config

docker/login:
	@echo $(DOCKERHUB_PASSWORD) | docker login -u $(DOCKERHUB_USERNAME) --password-stdin

docker/push: ## Push image to ECR
	@docker pull $(BASE_IMAGE_NAME)
	@docker tag $(BASE_IMAGE_NAME) base-prod:latest
	@docker build . -t $(IMAGE_NAME) -f $(APP_ROOT)/docker/Dockerfile.prod
	@docker push $(IMAGE_NAME)


docker/push-base:
	@docker pull $(BASE_IMAGE_NAME)
	@docker tag $(BASE_IMAGE_NAME) base-prod:latest
	@docker build . -t $(BASE_IMAGE_NAME) -f $(APP_ROOT)/docker/Dockerfile.base-prod
	@docker push $(BASE_IMAGE_NAME)

help:
	@echo -e "\n Usage: make [target]\n"
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
	@echo -e "\n"
