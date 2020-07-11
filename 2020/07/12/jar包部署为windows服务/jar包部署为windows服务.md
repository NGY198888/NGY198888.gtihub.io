---
title: jar包部署为windows服务
categories:
  - 后端
tags:
  - java
  - jar
  - windows服务
date: 2020-07-12 00:20:14
---
# 环境要求
  + 已经安装并配置好jdk
  + 有.NET4运行环境
  + 准备好可运行jar包
  + 下载好文件 [sample-minimal.xml](https://github.com/kohsuke/winsw/releases/download/winsw-v2.2.0/sample-minimal.xml) ，[WinSW.NET4.exe](https://github.com/kohsuke/winsw/releases/download/winsw-v2.2.0/WinSW.NET4.exe)

# 准备工作
  下载WinSW到jar目录下，sample-minimal.xml，WinSW.NET4.exe，统一两个的文件名为WinSW，假设jar文件是IntelligenScale.jar
# 修改WinSW.xml配置
  ``` xml
  <configuration>
  
  <!-- ID of the service. It should be unique accross the Windows system-->
  <id>IntelligenScale</id>
  <!-- Display name of the service -->
  <name>IntelligenScale</name>
  <!-- Service description -->
  <description>电子秤数据采集服务</description>
  
  <!-- Path to the executable, which should be started -->
  <executable>java</executable>
  <arguments>-jar IntelligenScale.jar</arguments>
  <startmode>Automatic</startmode>
  <log mode="append">
  <logpath>logs/service.log</logpath>
  </log>

</configuration>
  ```
# 创建运行文件
  + 安装服务(超管运行).bat `java -jar IntelligenScale.jar`
  + 卸载服务(超管运行).bat `WinSW.exe uninstall`
  + 运行这两个文件即可完成安装和卸载