src=$(dirname $(realpath "$0"))
. "$src/common.sh"

_require_cmd fuzzel

_dmenu() {
    local result=""
    local counter=0

    while IFS= read -r line; do
        counter=$((counter + 1))

        if [ -z "$result" ]; then
            result="$line"
        else
            result="$(printf '%s\n%s' "$result" "$line")"
        fi
    done

    echo "$result" | fuzzel -d --lines $counter "$@"
}
