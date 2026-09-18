#!/usr/bin/env bash

# base from waybar wiki but i modified it

CACHE="/tmp/weather_cache.json"

if [ "$1" == "0" ];
then
		if [[ -f "$CACHE" ]]; 
		then
				cat "$CACHE"
		else
				echo "{\"text\":\" 󰼵 \", \"tooltip\":\"click for data\"}"
		fi
		exit
fi

if [ "$1" == "w" ];
then
		xdg-open "https://wttr.in/$2"
fi

for i in {1..5}
do
		text=$(curl -s "https://wttr.in/$1?format=1")
		if [[ $? == 0 ]]
		then
				text=$(echo "$text" | sed -E "s/\s+/ /g")
				tooltip=$(curl -s "https://wttr.in/$1?format=4")
				if [[ $? == 0 ]]
				then
						tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g")
						echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}" > "$CACHE"
						exit
				fi
		fi
		sleep 2
done
echo "{\"text\":\"error\", \"tooltip\":\"error\"}" > "$CACHE"
