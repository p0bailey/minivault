#Authored by Phillip Bailey
.PHONY: all
.SILENT:
SHELL := /bin/bash

VAULT_VERSION = 1.5.5
VAULT_HOSTNAME = vault.traefik.me
TRAEFIK_ENABLED = true
COMPOSE_PROJECT_NAME=lab
VAULT_ADDR=https://vault.traefik.me:8200
VAULT_SKIP_VERIFY=true
# SECDBPASS =
export VAULT_VERSION
export VAULT_HOSTNAME
export TRAEFIK_ENABLED
export COMPOSE_PROJECT_NAME
export VAULT_ADDR
export VAULT_SKIP_VERIFY
# export SECDBPASS


REQUIRED_BINS := vault mkcert gomplate multitail pwgen keepassxc-cli terraform
$(foreach bin,$(REQUIRED_BINS),\
    $(if $(shell command -v $(bin) 2> /dev/null),$(info Found required bin: `$(bin)`),$(error Please install `$(bin)`)))

all: print_vars
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


scenario_1_apply:
	cd demos/scenario-1/ \
	&& terraform init \
	&& terraform plan \
	&& terraform apply  -auto-approve

scenario_1_destroy:
	cd demos/scenario-1/ \
	&& terraform destroy   -auto-approve



print_vars:
	@echo
	@echo MiniVault variables.
	@echo Vault version: $$VAULT_VERSION
	@echo Vault address: $$VAULT_ADDR
	@echo

upgrade:  template
	make vault_stop \
	&& docker-compose -f docker-compose.yml up -d --build \
	&& make vault_unseal

template:
	gomplate   -f config/docker-compose.tmpl -o docker-compose.yml \
	&& gomplate   -f config/vault-config.tmpl -o vault/config/vault-config.hcl \
	&& gomplate   -f config/Dockerfile.tmpl -o Dockerfile

unset:
	chmod +x .unset.sh && ./.unset.sh


build:  delete template ## Build and Run MiniVault
	export | grep VAULT && \
	docker-compose -f docker-compose.yml up -d --build \
	&& cd config && ./vault-init.sh  init && ./vault-init.sh  prep

delete:  ## Stop and delete MiniVault and its resources.
	docker-compose down -v  --rmi all  --remove-orphans && \
	rm -rf vault/data/ && \
	rm -f vault/config/*.txt && \
	rm -f vault/config/vault-config.hcl && \
	rm -f vault/logs/* && \
	rm -f unseal_key.txt && \
	rm -f Dockerfile


vault_stop:  ## Stop MiniVault
	export COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) && docker-compose  -f docker-compose.yml stop

vault_start: ## Start and unseal MiniVault
	docker-compose  -f docker-compose.yml start
	make vault_unseal

vault_unseal:
	cd config && ./vault-init.sh unseal


vault_logs:
	multitail -f -c vault/logs/audit.log

push:
	git add . && git commit -m "`date`" && git push origin `git rev-parse --abbrev-ref HEAD` || true

pull:
	git pull origin `git rev-parse --abbrev-ref HEAD`

open:
	open https://vault.traefik.me:8200

show_secure_db_entries:
	cd config && ./vault-init.sh show_secure_db_entries

get_secure_db_entries_admin_user_password:
		cd config && ./vault-init.sh get_secure_db_entries users_admin
