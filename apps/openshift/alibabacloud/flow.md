## Flow

1. 注册域名并认证
2. 使用 ROS 模板创建云资源：ECS 服务器、域名、NAT 网关、VPC等
3. 用域名和准备的公钥（ssh-keygen 生成即可）去 Redhat [官网控制台](consol.redhat.com)去获取 ISO 镜像
4. 将 ISO 转换 qcow2 格式，再制作成阿里云的自定义镜像
5. 将所有的 ECS 服务器的镜像更换成自定义镜像
6. 在 Redhat [官网控制台](consol.redhat.com) 配置 master/worker 节点后安装集群
7. 所有的 ECS 进入 pending 状态后，登录每个 ECS，使用磁盘拷贝的方式复制数据（数据盘->系统盘），卸载数据盘并重启
8. 等待各节点安装完成集群即部署完毕
