---
title: nodered入门
categories:
  - 物联网
tags:
  - 物联网
  - nodered
date: 2020-07-12 01:47:57
---

# 安装
   + 确保安装cnpm和node
   + cmd运行   `cnpm i -g node-red`
  
# 运行
   cmd运行 `node-red`    打开localhost:1880
# 安装dashboard模块
  + 在右上方的部署按钮右侧有个菜单，点击菜单，选择节点管理。
  + 搜索“dashboard”关键字，找到`node-red-dashboard`,点击安装

# dashboard可视化界面显示
  + 选择dashboard面板，可以在里面添加Tabs，Tabs添加分组，将UI节点加进分组，就 可以在管理平台显示了
  + 双击UI节点，出现属性面板，group这里进行分组，分到对应的tab去
  + 可视化地址localhost:1880/ui
  ![](nodered入门/1.png)
  ![](nodered入门/2.png)
  ![](nodered入门/3.png)
  ![](nodered入门/4.png)


