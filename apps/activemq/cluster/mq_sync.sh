#!/bin/bash

# need install rclone 【sudo apt update && sudo apt install】 rclone or  【sudo yum install rclone】

# 定义变量
server_ip="your_server_ip"
server_username="your_server_username"
server_password="your_server_password"

# 目标server的目录
target_path="your_target_path"

# 本机目录
source_path="your_source_path"


# 使用 rclone 同步数据
rclone sync \
    --log-file=$(dirname "$0")/sync.log \
    --log-level INFO \
    "${server_username}:${server_password}@${server_ip}:${target_path}" \
    "${source_path}"
