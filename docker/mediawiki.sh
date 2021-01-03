#!/bin/sh

set -eux

MYSQL_SERVER=db

cd /srv/http/wiki
composer update

create_wiki() {
	php maintenance/install.php \
		--dbserver $MYSQL_SERVER --dbname "$MYSQL_DATABASE" \
		--dbuser "$MYSQL_USER" --dbpass "$MYSQL_PASSWORD" \
		--installdbuser root --installdbpass "$MYSQL_ROOT_PASSWORD" \
		--server "$WIKI_URL" --scriptpath / \
		--pass "$WIKI_ADMIN_PASSWORD" "$WIKI_NAME" "$WIKI_ADMIN"
}

query() {
	mysql -h $MYSQL_SERVER -p"$MYSQL_ROOT_PASSWORD" -s "$@"
}

if [ -s LocalSettings.php ]; then
	:
elif [ -z "$(query -e "SHOW TABLES;" "$MYSQL_DATABASE" 2> /dev/null)" ]; then
	create_wiki
fi
