TRAEFIK_BRIDGE ?= traefiknet
USER_UID ?= $(shell id -ur)
USER_GID ?= $(shell id -gr)
NAME ?= wiki
DOMAIN ?= docker.localhost
HOSTNAME ?= $(NAME).$(DOMAIN)
MYSQL_IMAGE ?= amery/docker-alpine-mariadb
MYSQL_DATABASE ?= wiki
MYSQL_USER ?= $(MYSQL_DATABASE)
MYSQL_PASSWORD ?= user_password
MYSQL_ROOT_PASSWORD ?= root_password
NGINX_IMAGE ?= amery/docker-alpine-nginx
PHP_IMAGE ?= amery/docker-alpine-php7:7.4
WIKI_ADMIN ?= Admin
WIKI_ADMIN_PASSWORD ?= admin_password
WIKI_NAME ?= My Mediawiki
WIKI_NAMESPACE ?= $(shell echo "$(WIKI_NAME)" | tr ' ' '_')
WIKI_URL ?= https://$(HOSTNAME)
WIKI_CONTACT ?= $(NAME)@$(DOMAIN)
WIKI_PASSWORD_SENDER ?= $(NAME)-recovery@$(DOMAIN)
# https://www.browserling.com/tools/random-hex (64 digits)
WIKI_SECRET = 0000000000000000000000000000000000000000000000000000000000000000
# https://www.browserling.com/tools/random-hex (16 digits)
WIKI_UPGRADE_KEY = 0000000000000000
WIKI_LOGO_1X ?= $$wgResourceBasePath/resources/assets/wiki.png
