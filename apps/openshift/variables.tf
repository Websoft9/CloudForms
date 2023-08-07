variable "cloudname" {
    default = "alibabacloud"
}
#openshift集群资源部署的region
variable "region" {
    default = "cn-hongkong"
}
variable "access_key" {
    default = "LTAI******RYMp"
}
variable "secret_key" {
    default = "Jg9Q******Px8G"
}
#启动用于执行自动化部署脚本的服务器所在的vpc
variable "launcher_vpc_id" {
    default = "vpc-j6ci******yf5y"
}
#启动用于执行自动化部署脚本的服务器所在的交换机
variable "launcher_vswitch_id" {
    default = "vsw-j6cr******z0n6"
}
#用于执行自动化部署脚本的服务器的ssh登录密码，用户为root
variable "ssh_password" {
    default = "SPb6RNpk"
}
#openshift集群访问地址使用的域名，必须在上面AKSK所在的账户中
variable "base_domain" {
    default = "******.******"
}
#openshift集群名称，该名称将用于最后集群提供公网访问的域名地址，比如test.******.*******.test.******.****** 等一系列域名
variable "openshift_cluster_name" {
    default = "test"
}


#如果实际的阿里云vpc网络环境与一下网段配置不冲突可以使用默认配置
#openshift集群名称内部资源网段
variable "openshift_cluster_network" {
    default = "10.128.0.0/14"
}
#openshift集群master，worker节点服务器网段，注意不要与现有阿里云vpc包含的网段冲突
variable "openshift_machine_network" {
    default = "10.0.0.0/16"
}
#openshift集群service网段
variable "openshift_service_etwork" {
    default = "172.30.0.0/16"
}