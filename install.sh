#!/bin/sh

_check_command() {
    if ! command -v "$1" > /dev/null; then
        echo "$1: not found" >&2
        exit 1
    fi
}

for cmd in curl patch python3 tar unzip; do
    _check_command "$cmd"
done

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

mkdir -p "$config_home" "$data_home"

_confirm_replace() {
    read -p "'$path' already exists. Do you want to replace it? [y/N] " choice

    case "$choice" in
        y|Y)
            ;;
        *)
            return 1
            ;;
    esac
}

for config in foot fuzzel hypr nvim swaync user-dirs.dirs gtk-3.0 gtk-4.0; do
    path="$config_home/$config"

    if [ -e "$path" ]; then
        _confirm_replace || continue
    fi

    rm -rf "$path"
    cp "./$config" "$path" -r
done

for config in .zshrc .gtkrc-2.0; do
    path="$HOME/$config"

    if [ -e "$path" ]; then
        _confirm_replace || continue
    fi

    rm -rf "$path"
    cp "./$config" "$path" -r
done

mkdir -p thirdparty

curl -Lo thirdparty/install_gtk.py \
    "https://raw.githubusercontent.com/catppuccin/gtk/v1.0.3/install.py"

patch -p1 < install_gtk.patch

python3 thirdparty/install_gtk.py mocha blue

curl -Lo thirdparty/cursors.zip \
    "https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-blue-cursors.zip"

icons_dir="$data_home/icons"
mkdir -p "$icons_dir"

unzip thirdparty/cursors.zip -d "$icons_dir"

curl -Lo thirdparty/font.tar.xz \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

font_dir="$data_home/fonts/JetBrainsMono"
mkdir -p "$font_dir"

tar -xJf thirdparty/font.tar.xz -C "$font_dir"
fc-cache -fr

bg_dir="$data_home/backgrounds"
mkdir -p "$bg_dir"

cp backgrounds/* "$bg_dir"

read -p "Do you want to install my scripts? [Y/n] " choice

case "$choice" in
    y|Y|"")
        cp -r scripts "$data_home"
        ;;
esac

if command -v Telegram || command -v telegram-desktop; then
    read -p "Do you want to install Telegram theme? [Y/n] " choice

    case "$choice" in
        y|Y|"")
            url="https://t.me/addtheme/ctp_mocha"
            xdg-open "$url" || firefox "$url" || chromium "$url"
            ;;
    esac
fi

hyprctl reload
