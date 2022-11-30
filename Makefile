DOCKER ?= docker
DOCKER_COMPOSE ?= docker-compose

DOCKER_COMPOSE_UP_OPT ?=
SHELL = /bin/sh

# generated outputs
#
FILES = docker-compose.yml docker/Dockerfile nginx.conf \
	db.env mediawiki.env nginx.env \
	LocalSettings.php

CONFIG_MK = config.mk
GEN_MK = gen.mk

# scripts
#
CONFIG_MK_SH = $(CURDIR)/scripts/config_mk.sh
GET_VARS_SH = $(CURDIR)/scripts/get_vars.sh
GEN_MK_SH = $(CURDIR)/scripts/gen_mk.sh

# colours
#
PYGMENTIZE ?= $(shell which pygmentize)

ifneq ($(PYGMENTIZE),)
COLOUR_NGINX = $(PYGMENTIZE) -l nginx
COLOUR_YAML = $(PYGMENTIZE) -l yaml
else
COLOUR_NGINX = cat
COLOUR_YAML = cat
endif

# variables
#
TEMPLATES = $(addsuffix .in, $(FILES))
DEPS = $(GET_VARS_SH) $(TEMPLATES) Makefile
GEN_MK_VARS = $(shell $(GET_VARS_SH) $(TEMPLATES))

.PHONY: all files clean mrproper pull build
.PHONY: up start stop restart logs
.PHONY: update config inspect
ifneq ($(SHELL),)
.PHONY: shell
endif

all: pull build

#
#
clean:
	rm -f $(FILES) *~

mrproper: clean
	rm -rf overlay/*.lock overlay/vendor

.gitignore: Makefile
	for x in $(FILES); do \
		grep -q "^/$$x$$" $@ || echo "/$$x" >> $@; \
	done
	touch $@

$(GEN_MK): $(GEN_MK_SH) $(DEPS)
	$< $(GEN_MK_VARS) > $@~
	mv $@~ $@

$(CONFIG_MK): $(CONFIG_MK_SH) $(DEPS)
	$< $@ $(GEN_MK_VARS)
	touch $@

files: $(FILES) $(CONFIG_MK) $(GEN_MK) .gitignore

pull: files
	$(DOCKER_COMPOSE) pull
	git submodule update --init

build: files
	$(DOCKER_COMPOSE) build --pull

include $(GEN_MK)
include $(CONFIG_MK)

export COMPOSE_PROJECT_NAME=$(NAME)

up: files
	$(DOCKER_COMPOSE) up $(DOCKER_COMPOSE_UP_OPT)

start: files
	mkdir -p .overlay
	$(DOCKER_COMPOSE) up -d $(DOCKER_COMPOSE_UP_OPT)

stop: files
	$(DOCKER_COMPOSE) down --remove-orphans

restart: files
	$(DOCKER_COMPOSE) restart

logs: files
	$(DOCKER_COMPOSE) logs -f

ifneq ($(SHELL),)
shell: files
	$(DOCKER_COMPOSE) exec $(NAME) $(SHELL)
endif

update:
	git remote update --prune
	git submodule update --remote --init
	cd mediawiki; git submodule update --init --recursive

config: files
	$(DOCKER_COMPOSE) config | $(COLOUR_YAML)
	$(COLOUR_NGINX) nginx.conf

inspect:
	$(DOCKER_COMPOSE) ps
	$(DOCKER) network inspect -v $(TRAEFIK_BRIDGE) | $(COLOUR_YAML)
	$(DOCKER) network inspect -v $(NAME)_default | $(COLOUR_YAML)
