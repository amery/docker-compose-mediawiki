TRAEFIK_BRIDGE ?= traefiknet
NAME ?= wiki
HOSTNAME ?= $(NAME).docker.localhost
NGINX_IMAGE ?= amery/docker-alpine-nginx
PHP_IMAGE ?= amery/docker-alpine-php7
