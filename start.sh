#!/bin/bash

# Make sure we have a Steam Web API key
if [ -z "$STEAM_KEY" ] ; then
  echo "Make sure to include --env STEAM_KEY=(steamkeyhere)"
  echo "You can get your API key from https://steamcommunity.com/dev/apikey"
  echo
  echo "While you're at it, make sure you've exposed a port, like with -t 8080:80"
  exit
fi

# Set your Steam Web API key in the steam config file
cat /var/www/lanager/app/config/lanager/steam.php | sed s/"'apikey' => '',"/"'apikey' => '$STEAM_KEY',"/ > /tmp/steam.php
mv /tmp/steam.php /var/www/lanager/app/config/lanager/steam.php

# Kick off Apache and MySQL
service mysql start
service apache2 start

# Run the LANager installation command (needs the Steam API key, which is why we don't just run it in the docker build process)
php artisan lanager:install |grep -v -e "Please schedule" -e "From a terminal" -e "SteamImportUserStates.sh" -e "have a great LAN"


# Update Games Being Played every minute
while true; do bash /var/www/lanager/SteamImportUserStates.sh; sleep 60; done
