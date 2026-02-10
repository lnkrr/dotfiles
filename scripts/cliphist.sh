src=$(dirname $(realpath "$0"))

. "$src/common.sh"
. "$src/dmenu.sh"

_require_cmd cliphist wtype

history="$(cliphist list)"
index=$(_echon "$history" | awk '{$1=""; print substr($0,2)}' | _dmenu --index)

if [ $? -ne 0 ]; then
    exit 1
fi

i=0

while IFS= read -r line; do
    if [ "$i" -eq "$index" ]; then
        break
    fi

    i=$(($i + 1))
done <<EOF
$history
EOF

content="$(wl-paste)"

_echon "$line" | awk '{printf "%s", $1}' | cliphist decode | wl-copy
wl-paste
wtype -M ctrl -M shift v -m ctrl -m shift

_echon "$content" | wl-copy
