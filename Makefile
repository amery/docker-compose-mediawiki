DOCKER ?= docker
DOCKER_COMPOSE ?= docker-compose

PYGMENTIZE ?= $(shell which pygmentize)

DOCKER_COMPOSE_UP_OPT =

GEN_MK_VARS = TRAEFIK_BRIDGE NAME HOSTNAME

FILES = docker-compose.yml nginx.conf
SHELL = /bin/sh

CONFIG_MK = config.mk
GEN_MK = gen.mk

ifneq ($(PYGMENTIZE),)
COLOUR_NGINX = $(PYGMENTIZE) -l nginx
COLOUR_YAML = $(PYGMENTIZE) -l yaml
else
COLOUR_NGINX = cat
COLOUR_YAML = cat
endif

.PHONY: all files clean files pull build
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

.gitignore: Makefile
	for x in $(FILES); do \
		grep -q "^$$x$$" $@ || echo "$$x" >> $@; \
	done
	touch $@

$(GEN_MK): $(CURDIR)/gen_mk.sh Makefile
	$< $(GEN_MK_VARS) > $@~
	mv $@~ $@

$(CONFIG_MK): $(CURDIR)/config_mk.sh Makefile
	$< $@ $(GEN_MK_VARS)
	touch $@

files: $(FILES) $(CONFIG_MK) $(GEN_MK) .gitignore

pull: files
	$(DOCKER_COMPOSE) pull

build: files
	$(DOCKER_COMPOSE) build --pull

include $(GEN_MK)
include $(CONFIG_MK)

up: files
	$(DOCKER_COMPOSE) up $(DOCKER_COMPOSE_UP_OPT)

start: files
	mkdir -p .www
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

config: files
	$(DOCKER_COMPOSE) config | $(COLOUR_YAML)
	$(COLOUR_NGINX) nginx.conf

inspect:
	$(DOCKER_COMPOSE) ps
	$(DOCKER) network inspect -v $(TRAEFIK_BRIDGE) | $(COLOUR_YAML)
