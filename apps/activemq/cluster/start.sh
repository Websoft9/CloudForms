#!/bin/bash
mypass=$(grep 'pass =' rclone.conf | awk '{print $3}')
newpass=$(rclone obscure "$mypass")
sed -i "s|pass = $mypass|pass = $newpass|g" rclone.conf
chmod +x mq_sync.sh
current_path=$(pwd) && sed -i "s|{path}|$current_path|g" rclone-sync.service
sudo cp rclone-sync.service /etc/systemd/system/
sudo cp rclone-sync.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable rclone-sync.service
sudo systemctl enable rclone-sync.timer
sudo systemctl start rclone-sync.service
sudo systemctl start rclone-sync.timer
