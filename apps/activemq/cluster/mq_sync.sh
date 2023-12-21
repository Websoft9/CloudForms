#!/bin/bash

# User need set below parameters
server_ip=""
server_username=""
server_password=""
# e.g: /data/apps/data
server_path=""
backup_path=""


# Check
if [[ $EUID -ne 0 ]]; then
   echo "Need root or sudo" 
   exit 1
fi

if [[ -z "$server_ip" || -z "$server_username" || -z "$server_password" || -z "$server_path" || -z "$backup_path" ]]
then
  echo "Parameter is null"
  exit 1
fi

command -v rclone >/dev/null 2>&1 || { echo >&2 "rclone is required but it's not installed.  Aborting."; exit 1; }

# 使用 rclone 同步数据
rclone sync \
    --log-file=$(dirname "$0")/sync.log \
    --log-level INFO \
    "${server_username}:${server_password}@${server_ip}:${server_path}" \
    "${backup_path}"