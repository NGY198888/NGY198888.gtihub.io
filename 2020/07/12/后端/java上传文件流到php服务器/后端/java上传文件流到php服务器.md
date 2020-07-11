---
title: java上传文件流到php服务器
categories:
  - 后端
tags:
  - java
  - 上传
  - php
date: 2020-07-12 00:14:04
---
# 思路
  我的思路，通过http的post提交，post主要参数：
  +  file(即byte[]文件流)
  +  ext(文件扩展名)
# mvn依赖
  + httpclient(发起请求)
  + httpmime(使用到MultipartEntityBuilder)
  + fastjson(解析结果)
# java上传代码
``` java
/**
 * 将文件提交至文件服务器
 * @param fileByte 文件对象
 * @return FileStatus 上传结果
 */
public static ApiResult postFile(String url,byte[] fileByte, HashMap<String,String> paramsMap) {
    CloseableHttpClient httpclient = HttpClients.createDefault();
    CloseableHttpResponse response = null;
    ApiResult res=new ApiResult();
    try {
        HttpPost httpPost = new HttpPost(url);//"http://localhost:8844/common/Comm_Api/streamuploader?XDEBUG_SESSION_START=19300"
        MultipartEntityBuilder mEntityBuilder = MultipartEntityBuilder.create();
        mEntityBuilder.addBinaryBody("file", fileByte);
        if(paramsMap.size()>0){
            Set<String> keySet = paramsMap.keySet();
            for(String key:keySet) {
                String value = paramsMap.get(key);
                mEntityBuilder.addTextBody(key,value);
            }
        }
        httpPost.setEntity(mEntityBuilder.build());
        response = httpclient.execute(httpPost);
        int statusCode = response.getStatusLine().getStatusCode();
        if (statusCode == HttpStatus.SC_OK) {
            HttpEntity resEntity = response.getEntity();
            String  rs = EntityUtils.toString(resEntity);
            // 消耗掉response
            EntityUtils.consume(resEntity);
            try{
                if(!"".equals(rs)&&!"Read timed out".equals(rs))
                    res=JSONObject.parseObject(rs, ApiResult.class);
            }catch (Exception e){  }
            if(res.getCode()!=0){
                LogTool.getLogger().warn("http请求异常 url:"+url+" 结果："+rs);
            }
        }else{
            LogTool.getLogger().warn("http请求异常 url:"+url+" 结果：statusCode"+statusCode);
        }
    } catch (ParseException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        HttpClientUtils.closeQuietly(httpclient);
        HttpClientUtils.closeQuietly(response);
    }
    return res;
}
```
# php接收代码 使用到了tp5框架
``` php
接口代码：
/**接收文件流
 * 参数file 文件流
 * 参数ext 保存文件的扩展名
 * @return \app\common\webapi\Array|void
 */
function  streamuploader(){
    $streamData = isset($_POST['file'])? $_POST['file'] : '';
    $ext = isset($_POST['ext'])? $_POST['ext'] : '';
    $rs=(new Streamuploader())->receiveStreamFile($streamData,$ext);
    if($rs["ok"]){
        return Web::ok($rs["path"]);
    }else{
        return Web::err("上传失败".$rs["err"]);
    }
}

保存文件流代码：
/**接收保存流文件
 * @param string $streamData 文件流
 * @param string $ext   扩展名
 * @return array ok=true表示保存成功
 */
function receiveStreamFile(string $streamData,string $ext){
    $rs=["ok"=>false,"path"=>"","err"=>""];
    try{
        if(!empty($streamData)&&!empty($ext)){
            $ext=strtolower($ext);
            $uuid=uniqid("cam_");
            $uploadDir = 'uploads/Images';
            if($ext=="flv"){
                $uuid=uniqid("video_");
                $uploadDir = 'uploads/sf_video/'.date("Y-m-d");
            }
            // 创建目标目录
            if (!file_exists($uploadDir)) {
                mkdir($uploadDir,0777,true);//mkdir() 函数创建目录。
            }
            $path=$uploadDir."/".$uuid.".".$ext;
            file_put_contents($path, $streamData, true);
            $rs["ok"]=true;
            $rs["path"]=$path;
        }
    }catch (Exception $exception){
        $rs["err"]=$exception->getMessage();
        Log::error("保存文件流失败 ".$exception->getMessage()."|".$exception->getTraceAsString());
    }
    return $rs;
}

```
