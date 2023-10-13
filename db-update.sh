#!/bin/bash
# Original author: GHbasicuser
# Convert to bash script by directentis1 (https://github.com/directentis1)

# Configuration
BASE_SOURCE="http://rb2rs.freemyip.com/latest.zip"
RadioSure=0  # Put 1 to start RadioSure at the end of the script, otherwise 0
Minimum_waiting_time_to_redownload=12  # duration in hours

# Functions
start_radiosure() {
    wine "./RadioSure.exe"
    echo "Starting RadioSure..."
}

# Check if script is running in the appropriate directory
if [ ! -f "./RadioSure.exe" ]; then
    echo "Problem: This script doesn't seem to be running in the RadioSure folder."
    exit 1
fi

# If the 'Latest_RB2RS.zip' file is less than 12 hours old, exit
if [ -f "Stations/Latest_RB2RS.zip" ]; then
    last_modified=$(stat -c %Y "Stations/Latest_RB2RS.zip")
    current_time=$(date +%s)
    time_diff=$(( (current_time - last_modified) / 3600 ))
    if [ $time_diff -lt $Minimum_waiting_time_to_redownload ]; then
        if [ $RadioSure -eq 1 ]; then
            start_radiosure
        fi
        exit 0
    fi
    if [ $time_diff -gt 720 ]; then
        echo "RadioSure - The last successful update is more than 30 days old."
    fi
fi

# Download the latest "RB2RS" database
if ! wget -O "Stations/Latest_RB2RS.zip" "$BASE_SOURCE"; then
    echo "RadioSure - Didn't get a response from the Stations list Update server."
    if [ $RadioSure -eq 1 ]; then
        start_radiosure
    fi
    exit 1
fi

# Check if downloaded ZIP file is too small
zip_size=$(stat -c %s "Stations/Latest_RB2RS.zip")
if [ $zip_size -lt 800000 ]; then
    echo "RadioSure - The downloaded ZIP file seems too small. Update cancelled."
    if [ $RadioSure -eq 1 ]; then
        start_radiosure
    fi
    exit 1
fi

# Delete existing ".rsd" files
find Stations -name "stations-*.rsd" -delete

# Extract the ZIP file
unzip "Stations/Latest_RB2RS.zip" -d "Stations"

# Update the RadioSure.xml file with the current date and time
current_datetime=$(date +"%Y/%m/%d/%H/%M")
sed -i "s/<LastStationsUpdateCheck>.*<\/LastStationsUpdateCheck>/<LastStationsUpdateCheck>$current_datetime<\/LastStationsUpdateCheck>/" "RadioSure.xml"

# Show success message
echo "RadioSure - The Radio Stations database has been updated."

# Start RadioSure if requested
if [ $RadioSure -eq 1 ]; then
    start_radiosure
fi

exit 0