#!/bin/bash

# Setup error handling
set -e

# Enable debugging
#set -x

# Handle signals
exitHandler()
{
    log "Exit signal received, shutting down.."
    exit 0
}
trap exitHandler SIGINT SIGTERM SIGKILL SIGHUP

# Keep track of whether we just ran the fix or not
RAN_FIX=false

# Function for writing to the system log
function log()
{
    if [ ! -z ${1+x} ]; then
        logger -is -t intelquicksync-itunes-fix "${1}" 
    fi
}

# Function for detecting if iTunes is running
function detectionLoop()
{
    # Check if iTunes is running
    ITUNES_PID=`ps -A | grep -m1 "[i]Tunes.app/Contents/MacOS/iTunes" | awk '{print $1}'`

    # Verify that we don't have a valid PID,
    # but also keep "RAN_FIX" up to date
    if [[ ! "$ITUNES_PID" =~ ^[0-9]+$ ]]; then
        # Only continue if we didn't just run the fix
        if [ "$RAN_FIX" = false ]; then
            log "iTunes is not running, attempting to fix.."
            iTunesFix
            RAN_FIX=true
        fi
    else
        #echo "iTunes detected, skipping fix.."
        RAN_FIX=false
    fi
}

# Function for fixing the iTunes issue
function iTunesFix()
{
    # Check if the iTunes library service is running
    ITUNES_LIB_PID=`ps -A | grep -m1 "[c]om.apple.iTunesLibraryService" | awk '{print $1}'`

    # Verify that we have a valid PID
    if [[ "$ITUNES_LIB_PID" =~ ^[0-9]+$ ]]; then
        log "Running iTunes fix.."

        # Terminate the iTunes library service
        kill -9 $ITUNES_LIB_PID

        # Remove the "SC Info" folder
        rm -rf "/Users/Shared/SC Info/"

        log "Successfully ran iTunes fix!"
    else
        log "iTunes library service not running, skipping fix.."
    fi
}

# Start an infinite while loop
log "Starting.."
while :
do
    # Run the detection loop
    detectionLoop

    # Sleep for a second
    sleep 1
done
