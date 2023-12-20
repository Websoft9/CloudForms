## 描述：

​	使用rclone工具实现2台服务器的文本同步，只要主服务器的目录进行了修改那么次服务器的目录里面的内容就会跟着修改

在主服务器配置以下操作，在次服务器只要配置安装rclone操作即可



## 环境准备：

```
	准备rclone-current-linux-amd64.zip包
```



## 安装配置rclone软件

```
#使用wget下载

wget https://downloads.rclone.org/rclone-current-linux-amd64.zip

#解压zip包

unzip rclone-current-linux-amd64.zip

#进入压缩包复制二进制程序到系统目录里

cd rclone-v1.65.0-linux-amd64/

cp rclone /usr/bin/

#修改rclone权限

chown root:root /usr/bin/rclone

chmod 755 /usr/bin/rclone
```



## 编写rclone服务

```
#执行`rclone config`命令创建或配置rclone的配置文件

[root@aa-01 ~]# rclone config

    2023/12/20 14:38:12 NOTICE: Config file "/root/.config/rclone/rclone.conf" not found - using defaults
    
    No remotes found, make a new one?
    
    n) New remote
    
    s) Set configuration password
    
    q) Quit config
    
    n/s/q> q（选择q）

#文件默认放在/root/.config/rclone/rclone.conf
#这里我们选择手动配置
```



### 编写rclone.conf文件

```
[remote]

type = sftp 

host = 你的ip号

user = root 

pass = zzLZ9PwBbHi77A7eVESYZGd445Fjv9BiHUAj  

port = 22

path = /root/test02                 #远程目录的路径

shell_type = unix                   #指定连接到SFTP服务器所使用的shell类型

md5sum_command = md5sum             #指定计算文件md5sum的命令

sha1sum_command = sha1sum           #指定计算文件sha1sum的命令

```

```
> 注意：使用`rclone obscure`命令将配置文件中的敏感信息值转换为一段看起来随机的字符串：rclone obscure "密码" 然后复制放入rclone.conf中
```



### 编写rclone-sync.service系统服务文件

```
[Unit]

Description=Rclone Service

Wants=network-online.target

After=network-online.target

[Service]

Type=simple

ExecStart=/usr/bin/rclone sync /source/path /destination/path

Restart=on-failure

RestartSec=5

User=root

Group=root

StandardOutput=file:/path/to/logfile.log

StandardError=file:/path/to/error.log

[Install]

WantedBy=multi-user.target

#这个服务文件指定了/usr/bin/rclone sync /source/path /destination/path命令作为服务运行的具体命令，其中/source/path和/destination/path分别是源目录和目标目录的路径


```

### 创建存放日志的文件

```
/path/to/logfile.log

/path/to/error.log
```

### 编写rclone-sync.timer时间同步文件



```
[Unit]

Description=Runs rclone-sync.service every second

 

[Timer]

OnUnitActiveSec=1s

Unit=rclone-sync.service

 

[Install]

WantedBy=timers.target
```



### 启动服务

```
#重新加载systemd的配置文件

systemctl daemon-reload

systemctl start rclone-sync.service

#设置开机自启

systemctl enable rclone-sync.service

#启动名为"rclone-sync"的定时器

systemctl start rclone-sync.timer
```







