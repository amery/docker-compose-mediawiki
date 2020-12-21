TRAEFIK_BRIDGE ?= traefiknet
NAME ?= wiki
HOSTNAME ?= $(NAME).docker.localhost
MYSQL_IMAGE ?= amery/docker-alpine-mariadb
MYSQL_DATABASE ?= wiki
MYSQL_USER ?= $(MYSQL_DATABASE)
MYSQL_PASSWORD ?= user_password
MYSQL_ROOT_PASSWORD ?= root_password
NGINX_IMAGE ?= amery/docker-alpine-nginx
PHP_IMAGE ?= amery/docker-alpine-php7
