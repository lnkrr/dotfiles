#!/bin/sh

_confirm() {
    read -p "'$path' already exists. Do you want to replace it? [y/N] " choice

    case "$choice" in
        y|Y)
            ;;
        *)
            return 1
            ;;
    esac
}

for config in foot fuzzel hypr nvim swaync user-dirs.dirs; do
    path="${XDG_CONFIG_HOME:-$HOME/.config}/$config"

    if [ -e "$path" ]; then
        _confirm || continue
    fi

    rm -rf "$path"
    cp "./$config" "$path" -r
done

for config in .zshrc; do
    path="$HOME/$config"

    if [ -e "$path" ]; then
        _confirm || continue
    fi

    rm -rf "$path"
    cp "./$config" "$path" -r
done
