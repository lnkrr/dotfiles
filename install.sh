#!/bin/sh

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

python3 thirdparty/install_gtk.py mocha blue

curl -Lo thirdparty/font.tar.xz \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

font_dir="$data_home/fonts/JetBrainsMono"
mkdir -p "$font_dir"

tar -xJf thirdparty/font.tar.xz -C "$font_dir"
fc-cache -fr

if command -v Telegram || command -v telegram-desktop; then
    read -p "Do you want to install Telegram theme? [Y/n] " choice

    case "$choice" in
        y|Y|"")
            url="https://t.me/addtheme/ctp_mocha"
            xdg-open "$url" || firefox "$url" || chromium "$url"
            ;;
    esac
fi
