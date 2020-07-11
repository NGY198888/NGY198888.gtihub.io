---
title: taro笔记
categories:
  - 前端
tags:
  - taro
  - 小程序
date: 2020-07-12 00:35:49
---
# 分享的问题
  onShareAppMessage是分享前的拦截函数，我们在这里设置分享标题和要跳转的链接，但是它只在页面生效，如果是在组件里面写onShareAppMessage，是不会触发的。组件和页面之间隔了很多层级，props传递就导致很多中间组件需要调整，不好处理。
  + # 处理方案
    + 修改组件和页面的代码
      - 组件修改:分享按钮带上data-title，data-path，这是onShareAppMessage返回需要的数据结构
      `<Button data-title={"好运分享"} data-path={'xxxx?id=xxx'} openType="share">分享</Button>`
        
      - 页面修改onShareAppMessage，ops.target.dataset里面包含了title，path
      ``` js
      onShareAppMessage(ops){
            return ops.target.dataset;
      }
      ```

