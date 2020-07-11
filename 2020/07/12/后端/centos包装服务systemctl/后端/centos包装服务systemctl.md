---
title: centos包装服务systemctl
categories:
  - 后端
tags:
  - contos
  - 服务
date: 2020-07-12 00:42:58
---
# 将frpc包装成服务，开机启动
## 在frpc执行文件目录下打pwd，找到当前路径，比如/root/frp_0.33.0_linux_amd64/
## 新建frpc.service文件
编辑内容
``` js
[Unit]
Description=Frp Client Service
After=network.target
[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/root/frp_0.33.0_linux_amd64/frpc -c /root/frp_0.33.0_linux_amd64/frpc.ini
ExecReload=/root/frp_0.33.0_linux_amd64/frpc reload -c /root/frp_0.33.0_linux_amd64/frpc.ini
[Install]
WantedBy=multi-user.target
```
## 将上面的文件复制到 /usr/lib/systemd/system目录下
## 启动 
   `systemctl start frpc`
## 设置开机启动  
   `systemctl enable frpc`
##  查看服务状态  
   `systemctl status frpc` 
   当看到 `Active: active (running)`，即为已启动成功，其他的状态是未启动成功