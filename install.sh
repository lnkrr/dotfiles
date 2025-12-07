#!/bin/sh

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$config_home" "$data_home"

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
    path="$config_home/$config"

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

mkdir -p thirdparty

curl -Lo thirdparty/install_gtk.py \
    "https://raw.githubusercontent.com/catppuccin/gtk/v1.0.3/install.py"

python3 thirdparty/install_gtk.py mocha blue

curl -Lo thirdparty/font.tar.xz \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

font_dir="$data_home/fonts/JetBrainsMono"
mkdir -p "$font_dir"

tar -xJf thirdparty/font.tar.xz -C "$font_dir"
fc-cache -fr
