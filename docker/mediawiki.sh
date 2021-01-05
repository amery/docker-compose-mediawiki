#!/bin/sh

set -eu

MYSQL_SERVER=db

query() {
	mysql -h $MYSQL_SERVER -p"$MYSQL_ROOT_PASSWORD" -s "$@"
}

cd /srv/http/wiki
run-user composer update

if [ -z "$(query -e "SHOW TABLES;" "$MYSQL_DATABASE" 2> /dev/null)" ]; then
	rm -f LocalSettings.php
	run-user php maintenance/install.php \
		--dbserver $MYSQL_SERVER --dbname "$MYSQL_DATABASE" \
		--dbuser "$MYSQL_USER" --dbpass "$MYSQL_PASSWORD" \
		--installdbuser root --installdbpass "$MYSQL_ROOT_PASSWORD" \
		--server "$WIKI_URL" --scriptpath / \
		--pass "$WIKI_ADMIN_PASSWORD" "$WIKI_NAME" "$WIKI_ADMIN"
	rm LocalSettings.php
	ln -s OurLocalSettings.php LocalSettings.php
else
	run-user php maintenance/update.php
fi
