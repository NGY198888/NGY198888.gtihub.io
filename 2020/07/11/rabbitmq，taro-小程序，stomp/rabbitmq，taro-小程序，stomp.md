---
title: 'rabbitmq，taro,小程序，stomp'
date: 2020-07-11 03:00:55
tags:
---
## stompjs下载，（不要用npm安装stomp）
[下载地址](https://github.com/rabbitmq/rabbitmq-web-stomp-examples/tree/master/priv)

## rabbitmq的连接配置
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200701174211411.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L05HWTE5ODg4OA==,size_16,color_FFFFFF,t_70)

## 基于Taro，stomp的RabbitMQ消费者实现

```javascript
import config from  './config'
import {Stomp as stompjs} from './stomp'
import Taro from '@tarojs/taro'
import { isString } from 'lodash';
//MQ消费者,用于订阅RabbitMQ队列
//用法
// let mqConsumer=  MqConsumer.subscribe_queue("队列名",(data) => {
//     //收到数据
//     let msg =JSON.parse(data.body); 
//     console.log("mq消息",msg);
//     pd_layer.msg(data.body);
// })
// setTimeout(function(){
//   mqConsumer.send({a:1});
// }
export default class MqConsumer{
    serverUrl=null;
    ws=null;
    client=null;
    queue=null;
    onMsg=null;
    count=0;
    t=null;
    MAX=200;
    socketOpen=false;
    sendMsgQueue = []
    constructor(queue,onMsg){
        this.queue=queue;
        this.onMsg=onMsg;
        this.serverUrl = config.hostname+":"+config.port;  // rabbitmq服务的地址与端口号
        this.connect(); 
    }
    send(msg){
        let that=this;
        if(msg){
            if (that.socketOpen) {
                that.client.send(that.queue,{},isString(msg)?msg:JSON.stringify(msg));
            } else {
                that.sendMsgQueue.push(msg)
            }
        }
    }
    connect(){
        // 初始化 ws 对象
        this.socketOpen = false
        let that=this;
        function sendSocketMessage(msg) {
            if(msg){
                if (that.socketOpen) {
                    Taro.sendSocketMessage({
                        data: msg
                    })
                } else {
                    that.sendMsgQueue.push(msg)
                }
            }
        }

        /////////////////////////////////////////////////////
        this.ws = { send: sendSocketMessage,  onopen: null,  onmessage: null }
        Taro.connectSocket({
            url: `ws://${this.serverUrl}/ws`
        }).then(st=>{
            this.ws.st=st;
        })
       
        Taro.onSocketOpen(function (res) {
            console.log('WebSocket连接已打开！')
            that.socketOpen = true
            for (var i = 0; i < that.sendMsgQueue.length; i++) {
                sendSocketMessage(that.sendMsgQueue[i])
            }
            that.sendMsgQueue = []
            that.ws.onopen && that.ws.onopen()
        })
        Taro.onSocketMessage(function (res) {
            console.log('ws消息:')
            that.ws.onmessage && that.ws.onmessage(res)
        })
        Taro.onSocketError(function (res) {
            console.log('ws异常！',res)
            that.socketOpen = false
            that.reConnect(that);
        })
        Taro.onSocketClose(function (res) {
            console.log('ws断开！',res)
            that.socketOpen = false
            that.reConnect(that);
        })
        this.setClient();
    }
    setClient(){
        // 获得Stomp client对象
        stompjs.setInterval = function () { }
        stompjs.clearInterval = function () { }
        this.client = stompjs.over(this.ws);
        // 设置心跳
        this.client.heartbeat.outgoing = 0
        this.client.heartbeat.incoming = 0
        // 定义连接成功回调函数
        let onConnect = () => {
            console.log('连接MQ成功')
            var headers ={};
            //  headers.durable=false;
            //  headers['auto-delete']=false;
            //  headers['exclusive']=false;
            this.client.subscribe(this.queue, this.onMsg||(function(data) {
                var msg = data.body;
                console.log("MQ消息：" + msg);
            }),headers);        
        }
        let that=this;
        let _onError =(err) => {
            console.log("mq异常",err)
            that.reConnect(that);
        }
        // 定义客户端信息
        let clientInfo = {
            login: config.user,
            passcode: config.password,
            host:'/',
            
        }
        // 连接rabbitmq
        this.client.connect(clientInfo, onConnect, _onError)  // 用户名，密码，成功回调，错误回调，主机
    }
    reConnect(that){
        that.count ++;
        console.log("ws重连...【" + that.count + "】");
        //1与服务器已经建立连接
        if ( that.ws.st.readyState === 1) {
            clearTimeout(that.t);
            that.t=null;
            that.count=0;
        } else if(that.count >= that.MAX){
            alert("重连失败超过设定次数...");
        }else {
            //2已经关闭了与服务器的连接
            if (that.ws.st.readyState === 3) {
                that.connect();
            }
            that.t&&clearTimeout(that.t);
            //0正尝试与服务器建立连接,2正在关闭与服务器的连接
            that.t = setTimeout(function() {that.reConnect(that);}, 1000*10);
        }
    }
    static subscribe_queue(queue,onMsg){
       return new MqConsumer('/queue/'+queue,onMsg);
    }
    static subscribe_topic(queue,onMsg){
        //测试过，暂时使用不了
        return new MqConsumer('/topic/'+queue,onMsg);
    }
}
```
## 总结
+ 可以断线重连，一段时间后连接会自动断掉，原因我知道
+ queue使用正常，topic收不到消息不能正常使用，可能是我哪里设置有问题
