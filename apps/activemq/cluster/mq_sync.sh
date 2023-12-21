#!/bin/bash


#---------------------------------------------#
# You must set below path for sync

server_path=""
backup_path=""

#---------------------------------------------#

# Check
if [[ $EUID -ne 0 ]]; then
   echo "Need root or sudo" 
   exit 1
fi

if [[ -z "$server_path" || -z "$backup_path" ]]
then
  echo "Parameter is null"
  exit 1
fi

command -v rclone >/dev/null 2>&1 || { echo >&2 "rclone is required but it's not installed.  Aborting."; exit 1; }


rclone --config $(dirname "$0")/rclone.conf sync \
    --log-file=$(dirname "$0")/sync.log \
    --log-level INFO \
    remote:$server_path  $backup_path
