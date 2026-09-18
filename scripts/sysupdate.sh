#!/usr/bin/env bash

#From hyde project but modified to use tmux

# Check release
if [ ! -f /etc/arch-release ]; then
    exit 0
fi

aurhlpr="yay"
fpk_exup="flatpak update"
temp_file="/tmp/update_info"

[ -f "$temp_file" ] && source "$temp_file"

tmx() {
    SES="sysUpdate"
    tmux has-session -t $SES 2>/dev/null

    if [ $? != 0 ]
    then
        tmux new-session -d -s "$SES" -n update "$1"
        kitty tmux attach -t "$SES"
    else
        kitty tmux attach -t "$SES"
    fi
}


# Trigger upgrade
if [ "$1" == "up" ]; then
    if [ -f "$temp_file" ]; then
        # refreshes the module so after you update it will reset to zero
        trap 'pkill -RTMIN+20 waybar' EXIT
        # Read info from env file
        while IFS="=" read -r key value; do
            case "$key" in
            OFFICIAL_UPDATES) official=$value ;;
            AUR_UPDATES) aur=$value ;;
            FLATPAK_UPDATES) flatpak=$value ;;
            esac
        done <"$temp_file"

        command=$(cat <<EOF
clear
fastfetch
xdg-open "https://archlinux.org/news/" 2>/dev/null
printf '[Official] %-10s\n[AUR]      %-10s\n[Flatpak]  %-10s\n' '$official' '$aur' '$flatpak'
${aurhlpr} -Syu
$fpk_exup
read -n 1 -p 'Press any key to continue...'
EOF
)
        #kitty --title systemupdate sh -c "${command}"
        tmx "sh -c ${command}"
        
    else
        echo "No upgrade info found. Please run the script without parameters first."
    fi
    exit 0
fi

# Check for AUR updates
aur=$(${aurhlpr} -Qua | wc -l)
ofc=$(
    temp_db=$(mktemp -u /tmp/checkupdates_db_XXXXXX)
    trap '[ -f "$temp_db" ] && rm "$temp_db" 2>/dev/null' EXIT INT TERM
    CHECKUPDATES_DB="$temp_db" checkupdates 2>/dev/null | wc -l
)
fpk=$(flatpak remote-ls --updates | wc -l)

# Calculate total available updates
upd=$((ofc + aur + fpk))
# Prepare the upgrade info
upgrade_info=$(
    cat <<EOF
OFFICIAL_UPDATES=$ofc
AUR_UPDATES=$aur
FLATPAK_UPDATES=$fpk
EOF
)

# Save the upgrade info
echo "$upgrade_info" >"$temp_file"
# Show tooltip
if [ $upd -eq 0 ]; then
    upd="" #Remove Icon completely
    # upd="󰮯"   #If zero Display Icon only
    echo "{\"text\":\"󰊠 $upd\", \"tooltip\":\" Packages are up to date\"}"
else
    echo "{\"text\":\"󰮯 $upd\", \"tooltip\":\"󱓽 Official $ofc\n󱓾 AUR $aur\n󰏓 Flatpak $fpk\"}"
fi
