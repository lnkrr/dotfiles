#!/bin/sh

src=$(dirname $(realpath "$0"))

. "$src/common.sh"
. "$src/dmenu.sh"

_require_cmd swww

bg_dir="${XDG_DATA_HOME:-$HOME/.local/share}/backgrounds"

if ! [ -d "$bg_dir" ]; then
    exit 1
fi

set -- "$bg_dir"/*

if [ "$1" = "$bg_dir/*" ]; then
    exit 1
fi

bg_names=""

for file in "$@"; do
    name="${file##*/}"
    name="${name%.*}"

    if [ -z "$bg_names" ]; then
        bg_names="$name"
    else
        bg_names="$(printf '%s\n%s' "$bg_names" "$name")"
    fi
done

index=$(printf '%s\n' "$bg_names" | _dmenu --index)

if [ $? -ne 0 ]; then
    exit 1
fi

i=0

for file in "$@"; do
    if [ "$i" -eq "$index" ]; then
        break
    fi

    i=$(($i + 1))
done

_get_refresh_rate() {
    if ! _has_cmd wlr-randr; then
        echo 60
        return 0
    fi

    wlr-randr | grep current | awk '{print $3}'
}

rate=$(printf '%.0f\n' $(_get_refresh_rate))
swww img "$file" -t center --transition-fps $rate --transition-duration 1
