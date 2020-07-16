---
title: RESTClient笔记
date: 2020-07-11 02:58:33
categories: 
- 工具
tags:
- Rest
- http请求
- vscode插件
---
# Rest Client笔记
## Rest Client是什么
  是一个vscode插件，可以用它来进行http请求，GET,POST,PUT,DELETE都支持，这样测试接口在vscode也能进行，不用apiPost，浏览器等工具了
## 用法
   + 安装该插件
   + 新建*.http这种以http为后缀的文件
   + 文件内容编辑
  ```js
    @url=http://localhost:3333  //声明变量
    //###  表示一个请求
    ### //接口1 get请求，接收html内容，带了参数aa
    GET {{url}}?aa=1111


    ### //接口2 post请求，接收json，带了body请求体
    POST {{url}}
    content-type: application/json//声明接收json，跟请求体之间空一行

    {
        "name":"21111",
        "name2":"22222",
        "type":1
    }


    ### //接口3  请求头里带token认证
    POST {{url}}
    content-type: application/json
    Authorization: token xxx

    {
        "name":"21111",
        "name2":"22222",
        "type":1
    }
  ```
