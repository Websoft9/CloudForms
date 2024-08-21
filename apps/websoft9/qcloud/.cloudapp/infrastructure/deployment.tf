
# 随机密码（通过站内信发送）
resource "random_password" "cvm_password" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

# CVM
resource "tencentcloud_instance" "demo_cvm" {
  # CVM 镜像ID
  image_id = var.cvm_image_id

  # CVM 机型
  instance_type = var.cvm_type.instance_type

  # 云硬盘类型
  system_disk_type = var.cvm_system_disk_type

  # 云硬盘大小，单位：GB
  system_disk_size = var.cvm_system_disk_size

  # 公网IP（与 internet_max_bandwidth_out 同时出现）
  allocate_public_ip = var.cvm_public_ip

  # 最大带宽
  internet_max_bandwidth_out = var.max_bandwidth

  # 付费类型（例：按小时后付费）
  instance_charge_type = var.cvm_charge_type

  # 可用区
  availability_zone = var.app_zone.zone

  # VPC ID
  vpc_id = tencentcloud_vpc.main.id

  # 子网ID
  subnet_id = tencentcloud_subnet.main.id

  # 安全组ID列表
  security_groups = [tencentcloud_security_group.sg.id]

  # CVM 密码（由上方 random_password 随机密码生成）
  # password = random_password.cvm_password.result
  password = var.password
  # 启动脚本
  user_data_raw = <<-EOT
#!/bin/bash

# 检查目录是否存在，如果不存在则创建
directory="/usr/local/cloudapp"
if [ ! -d "$directory" ]; then
    mkdir "$directory"
fi

# 输出 .config 文件
echo "cloudappId=${var.cloudapp_id}" >>  $directory/.config
echo "cloudappName=${var.cloudapp_name}" >>  $directory/.config

# 执行启动脚本
if [ -f "/usr/local/cloudapp/startup.sh" ]; then
  sh /usr/local/cloudapp/startup.sh
fi
    EOT
}


# VPC
resource "tencentcloud_vpc" "main" {
  name              = "demo_websoft_vpc"
  availability_zone = var.app_zone.zone
  cidr_block        = "10.0.0.0/12"
  is_multicast      = "false"
  count             = 1
}

# 子网
resource "tencentcloud_subnet" "main" {
  name              = "demo_websoft_subnet"
  availability_zone = var.app_zone.zone
  cidr_block        = "10.0.0.0/24"
  is_multicast      = "false"
  vpc_id            = tencentcloud_vpc.main.id
  count             = 1
}


# 安全组
resource "tencentcloud_security_group" "sg" {
  name        = "demo_websoft_security_group"
  description = "cloudapp"
  count       = 1
}

# 入规则
resource "tencentcloud_security_group_rule" "ingress" {
  security_group_id = tencentcloud_security_group.sg.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "TCP"
  port_range        = "22,80,443,9000,9001"
  policy            = "ACCEPT"
  description       = "ingress all"
  count             = 1
}
# 出规则
resource "tencentcloud_security_group_rule" "egress" {
  security_group_id = tencentcloud_security_group.sg.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "ACCEPT"
  description       = "egress all"
  count             = 1
}

# 输出
output "main" {
  value       = "http://${tencentcloud_instance.demo_cvm.public_ip}:9000"
  description = "应用访问入口，用户名ubuntu，密码为服务器密码"
}

