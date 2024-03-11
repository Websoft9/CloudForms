需要准备的资源
  阿里云(https://www.aliyun.com/)： 
    域名：
      一级域名/子域名：<baseDomain>
      公网解析       ：api.<clusterName> | *.apps.<clusterName> -> CNAME -> 公网负载均衡dns
      PrivateZone解析：api | *.apps | api-int                   -> CNAME -> 内网负载均衡dns
    网络：
      专有网络       ：专有网络VPC
      交换机         ：主机所在区域均需创建交换机VSW
      公网弹性IP     ：按流量计费200M带宽
      公网NAT网关    ：同时创建SNAT绑定公网弹性IP
    负载：
      内网NLB        ：监听80/443/6443/22623
      公网NLB        ：监听80/443/6443
      服务器组       ：worker80/worker443/master6643/master22623
    存储：
      对象存储OSS    ：用于存储openshift_discovery.qcow2
    主机：
      控制节点master ：4c/16G/100G/100G * 3
      计算节点worker ：2c/ 8G/100G/100G * 3 或更多
    安全组：
      控制节点master ：ssh端口、服务端口等允许网内访问
      计算节点worker ：ssh端口、服务端口等允许网内访问
  其他资源：
    密钥对：
      创建密钥对     ：从任意主机生成ssh-ed25519密钥对(公钥/私钥)
    系统镜像(https://console.redhat.com/)：
      创 建 集 群    ：在radhat控制台创建集群，输入<clusterName>、<baseDomain>等信息
      生成iso文件    ：在radhat控制台添加主机，输入公钥，选择full版本，即可生成镜像
      下载iso文件    ：建议从linux通过wget下载镜像至本地
      转换iso文件    ：将下载的iso文件转换成qcow2文件
      上传qcow2文件  ：将qcow2上传至阿里云OSS
      生成自定义镜像 ：在阿里云用上传的qcow2文件创建自定义镜像

基本步骤
  1、依次准备以上资源，主机必须挂载自定义镜像启动
  2、在redhat控制台发现主机后，配置master/worker后安装系统
  3、在redhat控制台等待主机进入pending状态后，登录主机复制磁盘数据，随后卸载数据盘并重启主机

需要用到的命令
  转换镜像格式：
    qemu-img convert -f raw -O qcow2 openshift.iso openshift.qcow2
  查看磁盘信息：
    sudo fdisk -u -l /dev/vdb
  复制磁盘数据：
    sudo dd if=/dev/vdb of=/dev/vda bs=`expr 512 * 32` count=`expr 7364574 / 32 + 1` status=progress

集群控制台
  https://console-openshift-console.apps.<clusterName>.<baseDomain>
  kubeadmin/<Redhat控制台生成的随机密码>

---------------------------------------------------------------------------------------------------------------------

扩展存储
  登录openshift控制台，可添加本地存储、云存储。

备份集群
  官方提供了需要备份的文件清单，可手工或者通过工具进行备份
  https://docs.openshift.com/container-platform/3.11/day_two_guide/environment_backup.html

容器迁移
  可在控制台导入容器镜像、git源，或通过CLI命令进行导入

------------------------------------------------------------------------------------------

OpenShift对K8s的增强
  1.提升稳定性
    除了包含K8s，还包含很多其他企业级组件，如认证集成、日志监控等
    使用次新版本的K8s为最新版本产品的组件，保证客户企业级PaaS产品的稳定性
  2.一个集群承载多租户和多应用
    基于K8s角色的访问控制(RBAC)便于为用户分配具有不同权限级别的角色
  3.简单和安全部署
    提供参数化部署输入、执行滚动部署、启用回滚到先前部署状态，以及通过触发器驱动自动部署
    红帽Openshift DeploymentConfig与K8s Deployment相互整合
    通过Pod安全策略来提升安全性，可以设置Pod以非root用户方式运行
  4.运行更多类型的应用负载
    推出OpenShift Container Storage等解决方案
    参与K8s容器存储接口(CSI)开源项目
  5.快速访问应用
    提供入口请求的自动负载均衡Router
    集成OVS的SDN，并实现虚拟网络隔离
  6.便捷管理容器镜像
    通过使用ImageStream，实现容器镜像构建、部署与镜像仓库的松耦合
    可以将Docker Image导入ImageStream中并使用

OpenShift对K8s生态的延伸
  1.完美集成CI/CD工具
    默认使用Tekton作为OpenShift的Pipeline，并且会继续发布并支持与Jenkins的集成
  2.开发运维一体化
    提供原生的Prometheus监控、警报和集成的Grafana仪表板
    将CoreOS Tectonic控制台的功能完全融入OpenShift中，提供运维能力很强的Cluster Console。
    以CoreOS作为OpenShift的宿主机操作系统
    将Operator作为集群组件和容器应用的部署方式
    后续可能用Quay替代OpenShift的Docker Registry
  3.全生命周期管理有状态应用
    Operator扩展K8s API，可以配置和管理复杂的、有状态应用程序的实例
    可以实现跨混合云的应用生命周期统一管理
    提供一个非常方便的容器应用商店OperatorHub
  4.实现对IaaS资源的管理
    引入Machine API，通过配置MachineSet实现IaaS和PaaS统一管理
    当OpenShift集群性能不足的时候，自动将基础架构资源加入OpenShift集群中
  5.实时更新集群
    集群可以从本地镜像仓库下载和安装更新
    操作系统基于CoreOS，具备平滑升级能力
  6.通过Istio实现新一代微服务架构
    Istio通过Envoy为服务添加轻量级分布式代理来管理对服务的请求。
  7.实现Serverless
    使用支持K8s的Serverless架构的Knative

------------------------------------------------------------------------------------------

https://alidocs.dingtalk.com/i/nodes/QOG9lyrgJPPNL2rXIp7L9rXAJzN67Mw4?cid=57521517735&corpId=dingd8e1123006514592&doc_type=wiki_doc&iframeQuery=utm_medium%3Dim_card%26utm_source%3Dim&utm_medium=im_card&utm_scene=team_space&utm_source=im# 「通过Assisted Installation在阿里云部署Openshift集群」


