#!/bin/bash


printf "Sure to continue? [Y/n] "
read -r choice

if [[ $choice == "n" ]];
then
    exit 0
fi

configfile="config"
i3config="/home/$USER/.config/i3/config"
backup=""

function deploy() {
    local block=$1
    local config=$(eval "echo $2")
    # local keybind=$3
    # local cmd=$4

    local dotfile="$block.config"

    if [ ! "$backup" ]
    then
        backup="backup/$(date +"$backupfmt")"
        mkdir -p $backup
    fi

    if [ "$config" ];
    then
        if [[ -f "$dotfile" || -d "$block" ]];
        then
            if [[ "$config" && -e "$config" ]];
            then
                mv "$config" "$backup/$dotfile"
            fi

            if [ -f "$dotfile" ];
            then
                cp "$dotfile" "$config"
            elif [ -d "$block" ];
            then
                echo "Select configuration for $block:"
                select file in $(ls "$block" -t); do
                    cp "$block/$file" "$config"
                    break
                done
            else
                exit 1
            fi
        else
            echo "Error: config file specified for block $block but no dotfile in directory."
            exit 1
        fi
    fi
#    if [ $keybind ];
#    then
#        echo "bindsym \"$keybind\" exec $cmd" >> "$i3config"
#    fi
}

registers=()
function reg() {
    registers+=("$1=$2")
}

function deploy-all() {
    for reg in "${registers[@]}"
    do
        block=$(echo "$reg" | cut -d'=' -f 1)
        path=$(echo "$reg" | cut -d'=' -f 2)
        deploy "$block" "$path"
    done
}


### TODO: print mv & cp commands instead of executing.

### edit from here

backupfmt="%s"

reg "i3"       "/home/$USER/.config/i3/config"
reg "termite"  "/home/$USER/.config/termite/config"
reg "amp"      "/home/$USER/.config/amp/config.yml"
reg "dunst"    "/home/$USER/.config/dunst/dunstrc"
reg "micro"    "/home/$USER/.config/micro/settings.json"
reg "xob"      "/home/$USER/.config/xob/styles.cfg"
reg "rofi"     "/home/$USER/.config/rofi/config.rasi"
reg "warp"     "/home/$USER/.warprc"
reg "zsh"      "/home/$USER/.zshrc"


deploy-all
