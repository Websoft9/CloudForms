# Readme

## What this?

This is a automatic backup solution for ActiveMQ, it can sync **Data directory** between your Master node and Slave Node.

## How to use?

1. Git this project and install rclone
  ```
  git clone https://github.com/Websoft9/terraform-library && cd terraform-library/apps/activemq/cluster && sudo -v ; curl https://rclone.org/install.sh | sudo bash
  ```

2. Modify the path parameters below at file  mq_sync.sh

   - server_path
   - backup_path

3. Modify the host parameters below at file rclone.conf

   - host
   - user
   - pass

4. Start it
   ```
   bash start.sh
   ```
