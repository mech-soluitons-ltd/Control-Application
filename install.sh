#!/bin/bash +v
set -e
echo "Getting updates"
sudo apt-get update
echo "Installing Git"
sudo apt-get install git -y
echo "Installing JDK"
sudo apt install openjdk-11-jre -y
if [ -d "/home/$USER/control" ];
then
  echo "Control Application already exists"
  read -p "Do you want to reinstall? (y|n)" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      sudo systemctl stop c3p
      sudo rm -rf /home/$USER/control
    else
      exit 0
  fi
fi
echo "Downloading Control Application"
git clone https://github.com/mech-soluitons-ltd/Control-Application
mv /home/$USER/Control-Application /home/$USER/control
echo "Enabling CSI"
echo $'\n#Enable CSI\nstart_x=1' | sudo tee -a /boot/config.txt
echo "Configuring config file for user: $USER"
sudo touch /home/$USER/control/config.json
sudo tee /home/$USER/control/config.json &>/dev/null <<EOF
{
  "logFilePath": "/home/$USER/control/logs/control.log",
  "distFolderPath": "/home/$USER/control/dist/",
  "downloadedGcodePath": "/home/$USER/control/gcode/",
  "streamFolderSavePath": "/home/$USER/control/media/",
  "dbFolderPath": "/home/$USER/control/h2db",
  "controlFolderPath": "/home/$USER/control/"
}
EOF
#sed -i "s/pi/$USER/g" control/config.json
echo "Creating system service"
if test -f "/etc/systemd/system/c3p.service"; then
  echo "C3P Service Found"
  echo "Removing existing C3P Service"
  sudo rm /etc/systemd/system/c3p.service
fi
sudo touch /etc/systemd/system/c3p.service
sudo tee /etc/systemd/system/c3p.service &>/dev/null <<EOF
[Unit]
Description=Cloud 3D Print Control Application
After=multi-user.target

[Service]
WorkingDirectory=/home/$USER
ExecStartPre=/home/$USER/control/update.sh
ExecStart=sudo java -cp /home/$USER/control/SerialCommunicator-C3P-v0.1-jar-with-dependencies.jar com.cloud3dprint.Main /home/$USER/control/config.json
User=root
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "Making Upgrade Service"
if test -f "/etc/systemd/system/c3pUpgrade.service"; then
  echo "C3P Upgrade Service Found"
  echo "Removing existing C3P Upgrade Service"
  sudo rm /etc/systemd/system/c3pUpgrade.service
fi
sudo touch /etc/systemd/system/c3pUpgrade.service
sudo tee /etc/systemd/system/c3pUpgrade.service &>/dev/null <<EOF
[Unit]
Description=Cloud 3D Print Control Application Upgrade
After=multi-user.target

[Service]
WorkingDirectory=/home/pi
ExecStart=/home/pi/control/media/upgrade.sh
User=root
Type=simple
EOF

echo "Creating update file"
sudo touch /home/$USER/control/update.sh
sudo tee /etc/systemd/system/c3pUpgrade.service &>/dev/null <<EOF
#!/bin/bash +v
cd /home/$USER/control
git pull || true
EOF
chmod +x /home/$USER/control/update.sh

sudo systemctl daemon-reload
sudo systemctl enable c3p.service
sudo systemctl start c3p.service
printf '=%.0s' {1..45}
echo
printf '=%.0s' {1..45}
echo
cat << "EOF"
   ____ _                 _            
  / ___| | ___  _   _  __| |           
 | |   | |/ _ \| | | |/ _` |           
 | |___| | (_) | |_| | (_| |           
  \____|_|\___/ \__,_|\__,_|           
  _____ ____    ____       _       _   
 |___ /|  _ \  |  _ \ _ __(_)_ __ | |_ 
   |_ \| | | | | |_) | '__| | '_ \| __|
  ___) | |_| | |  __/| |  | | | | | |_ 
 |____/|____/  |_|   |_|  |_|_| |_|\__|
                                       
EOF
printf '=%.0s' {1..45}
echo
printf '=%.0s' {1..45}
echo
echo "Setup complete"
echo "Welcome to Cloud3DPrint! Please go to $(hostname -I) to connect your 3D printer."
echo "Use 'sudo systemctl status c3p' to check the status of the application"
echo "Use 'sudo systemctl reload c3p' to reload the application"
echo "If you are using a Raspberry Pi Camera, please restart the system with 'sudo reboot' for it to be detected"
