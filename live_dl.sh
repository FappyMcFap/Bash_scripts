#!/bin/bash

# Serves to auto dl Twitch Livestreams
# Script requires cronjob to start it & yt-dlp
# Probably messy but does the job :)
# Made by FappyMcFap January 03 2022

# Specify the time you'd like script to end at line 32
# Configure variables: streamer & path

curdate=$(date +"%Y-%m-%d")
# What appears at the end of a twitch link. Ex: https://www.twitch.tv/shroud
streamer="shroud"
link="https://www.twitch.tv/$streamer"
path="/path/to/$streamer/Live"


yt-dlp -o ''$path'/%(title)s-%(id)s_%(upload_date)s.%(ext)s' --hls-use-mpegts $link 2>&1 | tee "$path/$curdate.log"

# Not pretty but uses grep to detect yt-dlp's error message that contains 'offline'
while cat /mnt/NAS/Videos/Twitch/$streamer/Live/$curdate.log | grep -i 'offline'; do

	# Sleep for 2m before retrying..
	sleep 2m
	# Update the current time
	currentime=$(date +%H:%M)
	yt-dlp -o ''$path'/%(title)s-%(id)s_%(upload_date)s.%(ext)s' --hls-use-mpegts $link 2>&1 | tee "$path/$curdate.log"
	# Remove the log file once we don't need it anymore
	rm "$path/$curdate.log"

	# End script if time is passed 21:00
	if [[ "$currentime" = "21:00" ]]; then
		break
	fi

done
