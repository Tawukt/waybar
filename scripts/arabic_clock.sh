#!/bin/bash

while true;do

		time=$(date "+%d - %H:%M")

		arabic_time=$(printf "%s" "$time" | sed \
				-e 's/0/٠/g' \
				-e 's/1/١/g' \
				-e 's/2/٢/g' \
				-e 's/3/٣/g' \
				-e 's/4/٤/g' \
				-e 's/5/٥/g' \
				-e 's/6/٦/g' \
				-e 's/7/٧/g' \
				-e 's/8/٨/g' \
				-e 's/9/٩/g')

		echo "{\"text\":\"${arabic_time}\", \"tooltip\":\"Arabic Clock\"}"
		sec=$(date +%S)
		sleep $((60 - 10#$sec))
done
