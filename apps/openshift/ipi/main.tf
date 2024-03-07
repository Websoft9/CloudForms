data "local_file" "pull_secret" {
  filename = "${path.root}/pull-secret.txt"
}
data "template_file" "userdata_sh" {
  template = file("${path.root}/userdate.sh.tpl")

  vars = {
    openshift_cluster_name = var.openshift_cluster_name
    pull_secret = file("${data.local_file.pull_secret.filename}")
    ak = var.access_key
    sk = var.secret_key
    cloudname = var.cloudname
    region = var.region
    base_domain = var.base_domain
    openshift_cluster_network = var.openshift_cluster_network
    openshift_machine_network = var.openshift_machine_network
    openshift_service_etwork = var.openshift_service_etwork
  }
}
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}
resource "alicloud_security_group" "launcher_group" {
  name        = "sg_launcher"
  description = "sg_launcher"
  vpc_id      = var.launcher_vpc_id
}
resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.launcher_group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "instance" {
  instance_name              = "openshift-launcher"
  instance_type              = "ecs.t5-lc1m2.small"                           #1C2G
  instance_charge_type       = "PostPaid"                                     #后付费模式

  system_disk_category       = "cloud_efficiency"
  system_disk_name           = "openshift-launcher"
  system_disk_description    = "openshift-launcher"
  system_disk_size           = 20

  host_name                  = "openshift-launcher"
  password                   = var.ssh_password
  image_id                   = "centos_7_9_x64_20G_alibase_20230613.vhd"

  security_groups            = alicloud_security_group.launcher_group.*.id
  vswitch_id                 = var.launcher_vswitch_id

  internet_max_bandwidth_out = 5                                              #分配公网IP,带宽峰值5Mbps/s
  internet_charge_type       = "PayByTraffic"                                 #按流量收费

  user_data                  = data.template_file.userdata_sh.rendered
}