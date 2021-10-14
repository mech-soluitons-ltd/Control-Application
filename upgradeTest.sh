#!/bin/bash

# Upgrade to v1.5.2
# Disable and stop control panel service
echo "Disabling and stopping control application service"
systemctl disable c3p.service
systemctl stop c3p.service

# Clear old database files
echo "Clearing database files"
rm -f /home/pi/control/h2db/test*

# Pull new JAR from repo
echo "Pulling newest files"
cd /home/pi/control
git pull --ff-only || true

# Re-enable and restart the control panel service
echo "Re-enabling and restarting control application service"
systemctl enable c3p.service
systemctl start c3p.service

echo "Control upgrade script finished"
