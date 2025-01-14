# Docker compose variables paths
COMPOSE_FILE := docker/docker-compose.yml
COMPOSE_PROJECT_NAME := core

ENV_FILE := .env

# Buildx variables
BUILDER_NAME ?= buildx

# Variables
HCL_FILE     ?= docker/docker-bake.hcl
TARGET       ?= default
TAG          ?=
OUTPUT       ?=
EXTRA_ARGS   ?=

# Include .env if it exists
ifneq ("$(wildcard $(ENV_FILE))","")
    include $(ENV_FILE)
    export $(shell sed 's/=.*//' $(ENV_FILE))
endif

# Export all variables
.EXPORT_ALL_VARIABLES:

##
## Live development with Docker Compose:
##

run: guard-COMPOSE_FILE guard-BUILDER_NAME
run: ## Run Docker Compose services and tail logs, syncing changes to live containers
	docker compose -f $(COMPOSE_FILE) build --builder $(BUILDER_NAME)
	docker compose -f $(COMPOSE_FILE) up --watch

clean: guard-COMPOSE_FILE
clean: ## Remove all Docker Compose resources including volumes and networks
	docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	docker network rm core || true

##
## Database management & setup:
##

# These should be written to be idempotent and not fail if already run
# These run automatically on first project start - this command allows
# developers to manually run additional migrations when needed
migrate: guard-COMPOSE_FILE
migrate: ## Run database migrations
	@if ! docker compose -f $(COMPOSE_FILE) ps data | grep -q "running"; then \
		echo "Starting database container..."; \
		docker compose -f $(COMPOSE_FILE) up -d data; \
		echo "Waiting for database to be ready..."; \
		sleep 5; \
	fi
	docker compose -f $(COMPOSE_FILE) exec data sh -c '\
		for f in /docker-entrypoint-initdb.d/*; do \
			if [ "$${f}" != "/docker-entrypoint-initdb.d/01-create-databases.sql" ]; then \
				psql -U postgres -d postgres -f "$${f}"; \
			fi \
		done'

##
## Development with Docker Compose:
##

up: guard-COMPOSE_FILE guard-BUILDER_NAME
up: ## Start Docker Compose services in the background without reloading live changes
	docker compose -f $(COMPOSE_FILE) build --builder $(BUILDER_NAME)
	docker compose -f $(COMPOSE_FILE) up

down: guard-COMPOSE_FILE
down: ## Stop the Docker Compose services
	docker compose -f $(COMPOSE_FILE) down

restart: down up ## Restart the Docker Compose services

logs: guard-COMPOSE_FILE
logs: ## View logs for running Docker Compose services
	docker compose -f $(COMPOSE_FILE) logs -f

##
## Building images:
##

buildx: guard-BUILDER_NAME
buildx: ## Create or replace a Buildx container
	@if docker buildx inspect $(BUILDER_NAME) >/dev/null 2>&1; then \
		echo "Replacing existing Buildx builder: $(BUILDER_NAME)"; \
		docker buildx rm $(BUILDER_NAME); \
	fi
	docker buildx create --name $(BUILDER_NAME) --use --driver docker-container --bootstrap
	echo "Buildx builder $(BUILDER_NAME) created and ready to use."

# Inspect the current Buildx setup
buildx-inspect: guard-BUILDER_NAME
buildx-inspect:
	docker buildx inspect $(BUILDER_NAME)

# Remove the Buildx container
buildx-remove: guard-BUILDER_NAME
buildx-remove:
	docker buildx rm $(BUILDER_NAME)

# Bake TARGET using HCL_FILE
bake: guard-HCL_FILE guard-TARGET
bake:
	@echo "Building target '$(TARGET)' using $(HCL_FILE)"
	@docker buildx bake -f $(HCL_FILE) $(TARGET) \
		$(if $(TAG),--set app.tags=$(TAG)) \
		$(if $(OUTPUT),--set app.outputs=$(OUTPUT)) \
		$(EXTRA_ARGS)

bake-proxy: ## Bake the proxy image
	@echo "Building core proxy image"
	$(MAKE) bake TARGET=proxy

##
## Tools & helpers:
##

# Ask for confirmation before proceeding
confirm:
	@echo -n 'Are you sure [y/N] ' && read ans && [ $${ans:-N} = y ]

# Ensure environment variable is set
guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

update-version: ## Generate next semantic version using TYPE=patch|minor|major (default: patch)
	@if [ ! -f VERSION ]; then echo "v0.0.0" > VERSION; fi; \
	CURRENT_VERSION=$$(cat VERSION); \
	MAJOR=$$(echo $$CURRENT_VERSION | cut -d. -f1 | tr -d 'v'); \
	MINOR=$$(echo $$CURRENT_VERSION | cut -d. -f2); \
	PATCH=$$(echo $$CURRENT_VERSION | cut -d. -f3); \
	case "$(TYPE)" in \
		"major") \
			NEXT_MAJOR=$$((MAJOR + 1)); \
			NEXT_VERSION="v$$NEXT_MAJOR.0.0"; \
			;; \
		"minor") \
			NEXT_MINOR=$$((MINOR + 1)); \
			NEXT_VERSION="v$$MAJOR.$$NEXT_MINOR.0"; \
			;; \
		*) \
			NEXT_PATCH=$$((PATCH + 1)); \
			NEXT_VERSION="v$$MAJOR.$$MINOR.$$NEXT_PATCH"; \
			;; \
	esac; \
	echo "Current version: $$CURRENT_VERSION"; \
	echo "Next version: $$NEXT_VERSION"; \
	echo $$NEXT_VERSION > VERSION; \
	echo "Updated VERSION file"

help: ## Show help text
	@gawk -vG=$$(tput setaf 2) -vR=$$(tput sgr0) ' \
	  match($$0, "^(([^#:]*[^ :]) *:)?([^#]*)##([^#].+|)$$",a) { \
		if (a[2] != "") { printf "    make %s%-18s%s %s\n", G, a[2], R, a[4]; next }\
		if (a[3] == "") { print a[4]; next }\
		printf "\n%-36s %s\n","",a[4]\
	  }' $(MAKEFILE_LIST)
	@echo -e "" # blank line at the end
.DEFAULT_GOAL := help
