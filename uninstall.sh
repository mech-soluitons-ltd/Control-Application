#!/bin/bash +v
echo "Checking for existing Installation"
FILE=/etc/systemd/system/c3p.service
if test -f "$FILE"; then
  echo "C3P Service found"
  echo "Stopping C3P services"
  sudo systemctl disable c3p.service
  sudo systemctl stop c3p.service
  sudo rm /etc/systemd/system/c3p.service
  echo "Removed C3P services"
fi

FILE=/home/$USER/control
if test -f "$FILE"; then
  echo "Control Folder Found"
  echo "Removing application"
  sudo rm /home/$USER/control
  echo "Cloud 3D Print Application Removed"
fi
echo "Uninstallation Complete"
