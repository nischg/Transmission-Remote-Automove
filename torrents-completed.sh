#!/bin/sh
# Description:
# Checks for complete torrents in transmission folder, stops & moves them

MOVEDIR=~/torrents/completed

# get ratio limit value
RATIOLIMIT=`transmission-remote -si | grep "Default seed ratio limit:" | cut -d \: -f 2`

# get torrent list from transmission-remote list
# delete first / last line of output
# remove leading spaces
# get first field from each line
TORRENTLIST=`transmission-remote --list | sed -e '1d;$d;s/^ *//' | cut -s -d " " -f1`

# for each torrent in the list
for TORRENTID in $TORRENTLIST
do
    echo "* * * * * Operations on torrent ID $TORRENTID starting. * * * * *"
    
    # check if torrent was started
    STARTED=`transmission-remote --torrent $TORRENTID --info | grep "Id: $TORRENTID"`
    # echo " - started state = $STARTED" # debug message
    
    # check if torrent download is completed
    COMPLETED=`transmission-remote --torrent $TORRENTID --info | grep "Percent Done: 100%"`
    # echo " - completed state = $COMPLETED" # debug message
    
    # check torrent's current state is "Stopped"
    STOPPED=`transmission-remote --torrent $TORRENTID --info | grep "State: Finished"`
    # echo " - torrent stopped seeding = $STOPPED" # debug message
    
    # check to see if ratio-limit-enabled is true
    if [ "$RATIOLIMIT" != "Unlimited" ]; then
        # check if torrent's ratio matches ratio-limit
        CAPPED=`transmission-remote --torrent $TORRENTID --info | grep "Ratio: $RATIOLIMIT"`
    fi

  # if the torrent is "Stopped" after downloading 100% and seeding, move the files and remove the torrent from Transmission
  
  if  [ "$STARTED" != "" ] && [ "$COMPLETED" != "" ] && [ "$STOPPED" != "" ] && { [ "${CAPPED+x}" = x ] && [ -z "$CAPPED" ]; }; then
    echo "Torrent #$TORRENTID is completed."
    echo "Moving downloaded file(s) to $MOVEDIR."
    transmission-remote --torrent $TORRENTID --move $MOVEDIR
    echo "Removing torrent from list."
    transmission-remote --torrent $TORRENTID --remove
  else
    echo "Torrent #$TORRENTID is not completed. Ignoring."
  fi

  echo "* * * * * Operations on torrent ID $TORRENTID completed. * * * * *"

done