#!/bin/bash +v
echo "Stopping services"
sudo systemctl disable c3p.service
sudo systemctl stop c3p.service
sudo rm /etc/systemd/system/c3p.service
echo "Removing application"
sudo rm /home/$USER/control
echo "Cloud 3D Print Application Removed"
