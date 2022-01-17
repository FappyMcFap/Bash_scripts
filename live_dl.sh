#!/bin/bash

# Serves to auto dl Twitch Livestreams
# Script requires cronjob to start it (I have it running @ 20:00) & yt-dlp
# Probably messy but does the job :)
# Made by FappyMcFap January 03 2022

# Specify the time you'd like script to end at line 33
# Configure variables: streamer & path

curdate=$(date +"%Y-%m-%d")
# What appears at the end of a twitch link. Ex: https://www.twitch.tv/shroud
streamer="shroud"
link="https://www.twitch.tv/$streamer"
path="/path/to/$streamer/Live"

# Create folders if they don't exist
if [ ! -d $path ]; then
	mkdir -p $path
fi

/usr/local/bin/yt-dlp -o ''$path'/%(description)s-%(id)s_%(upload_date)s.%(ext)s' --hls-use-mpegts $link 2>&1 | tee "$path/$curdate.log"

# Not pretty but uses grep to detect yt-dlp's error message that contains 'offline'
while cat $path/$curdate.log | grep -i 'offline'; do

	# Sleep for 2m before retrying..
	sleep 2m
	# Update the current time
	curtime=$(date +%H:%M)

	# If time = 21:00 end script
	if [[ "$curtime" = "21:00" ]]; then
		break
	else
		/usr/local/bin/yt-dlp -o ''$path'/%(description)s-%(id)s_%(upload_date)s.%(ext)s' --hls-use-mpegts $link 2>&1 | tee "$path/$curdate.log"
	
		# Delete the log file when we don't need it anymore
		rm "$path/$curdate.log"

		# Convert leftover .part file to mp4 
		for file in *.part; do
			mv "$file" "${file%.part}.mp4"
		done
	fi
done
