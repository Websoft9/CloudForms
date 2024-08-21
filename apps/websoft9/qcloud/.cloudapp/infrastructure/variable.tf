# ==========================================================
#               下方变量通常需要根据实际情况修改
# ==========================================================

# CVM 镜像ID
variable "cvm_image_id" {
  type    = string
  default = "img-ofsesyzv"
}

# CVM 系统盘类型
variable "cvm_system_disk_type" {
  type    = string
  default = "CLOUD_HSSD"
}

# CVM 系统盘大小，单位：GB
variable "cvm_system_disk_size" {
  type    = number
  default = 50
}

# CVM 公网IP（与最大带宽同时存在）
variable "cvm_public_ip" {
  type    = bool
  default = true
}

# CVM 最大公网带宽
variable "max_bandwidth" {
  type    = number
  default = 1
}

# CVM 计费方式
variable "cvm_charge_type" {
  type    = string
  default = "POSTPAID_BY_HOUR"
}


# 用户选择的地域
variable "app_zone" {
  type = object({
    region = string
    zone   = string
  })
  default = {
    region = "ap-guangzhou"
    zone   = ""
  }
}


# ==========================================================
#                     下方变量通常不需要修改
# ==========================================================

# CVM 机型选择变量
variable "cvm_type" {
  type = object({
    region        = string
    region_id     = string
    zone          = string
    instance_type = string
  })
}

# CVM 用户自定义服务器密码
variable "password" {
  type = string
  default = ""
}


# ==========================================================
#                        云应用系统变量
# ==========================================================

# 云应用系统变量
variable "cloudapp_cam_role" {}
variable "cloudapp_id" {}
variable "cloudapp_name" {}
# variable "cloudapp_repo_server" {}
# variable "cloudapp_repo_username" {}
# variable "cloudapp_repo_password" {}
