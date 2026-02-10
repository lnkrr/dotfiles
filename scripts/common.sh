_echon() {
    printf '%s' "$@"
}

_error() {
    echo "error: $@" >&2
}

_fatal() {
    _error "$@"
    exit 1
}

_has_cmd() {
    command -v "$@" > /dev/null
}

_require_cmd() {
    for cmd in "$@"; do
        if ! _has_cmd "$cmd"; then
            _fatal "$cmd: not found"
        fi
    done
}
