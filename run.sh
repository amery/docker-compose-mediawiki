#!/bin/sh

set -eu
WS=$(dirname "$0")
CURDIR="$PWD"

if [ "x${1:-}" = "x-r" ]; then
	USER=root
	shift
else
	USER=
fi

die() {
	local x=

	if [ $# -eq 0 ]; then
		cat
	else
		for x; do
			printf "$x\n"
		done
	fi | sed -e "s|^|E/$(basename "$0"): |" -e 's|[ \t]\+$||' >&2
}

# detect service and workdir
#
case "$CURDIR" in
$WS/db|$WS/db/*)
	BASE="$WS/db"
	MODE=db
	;;
$WS/overlay|$WS/overlay/*)
	BASE=$WS/overlay
	MODE=mediawiki
	;;
$WS/mediawiki|$WS/mediawiki/*)
	BASE=$WS/mediawiki
	MODE=mediawiki
	;;
*)
	BASE="$CURDIR"
	MODE=mediawiki
esac

if [ "$CURDIR" != "$BASE" ]; then
	DIR="${CURDIR#$BASE/}"
else
	DIR=
fi

if [ "$MODE" = "db" ]; then
	DIR="/var/lib/mysql/$DIR"
	NAME="$MODE"
else
	DIR="/srv/http/wiki/$DIR"
	NAME="wiki"
fi

# find container
#
docker_compose() {
	cd "$WS"
	docker-compose "$@"
}

i=0
while true; do
	ID="$(docker_compose ps -q $NAME)"
	[ -z "$ID" ] || break

	: $((i = i + 1))
	[ $i -le 5 ] || die "$NAME: failed to start service"

	make -C "$WS" start
done

# command
[ $# -gt 0 ] || set -- /bin/sh

# -u/-w/-e
set -- -u "${USER:-appuser}" -w "$DIR" "$ID" "$@"
while read l; do
	set -- -e "$l" "$@"
done < "$WS/$MODE.env"

set -x
exec docker exec -ti "$@"
