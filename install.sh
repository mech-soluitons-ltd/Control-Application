#!/bin/bash +v
set -e
echo "Getting updates"
sudo apt-get update
echo "Installing Git"
sudo apt-get install git -y
echo "Installing JDK"
sudo apt install openjdk-11-jre -y
echo "Downloading Control Application"
git clone https://github.com/mech-soluitons-ltd/Control-Application
mv /home/$USER/Control-Application /home/$USER/control
echo "Configuring config file for user: $USER"
sed -i "s/pi/$USER/g" control/config.json
echo "Creating system service"
sudo touch /etc/systemd/system/c3p.service
sudo tee /etc/systemd/system/c3p.service &>/dev/null <<EOF
[Unit]
Description=Cloud 3D Print Control Application
After=multi-user.target

[Service]
WorkingDirectory=/home/$USER
ExecStart=java -cp /home/$USER/control/SerialCommunicator-C3P-v0.1-jar-with-dependencies.jar com.cloud3dprint.Main /home/$USER/control/config.json
User=$USER
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
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
echo "Welcome to Cloud3DPrint! Please go to $(hostname -I | sed 's/ /:8081 /g') to connect your 3D printer."
echo "Use 'sudo systemctl status c3p' to check the status of the application"
echo "Use 'sudo systemctl reload c3p' to reload the application"
