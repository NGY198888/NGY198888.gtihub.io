---
title: SKU选择算法笔记
categories:
  - 前端
tags:
  - SKU
  - 商城
  - 最小库存单元
date: 2020-07-12 00:48:08
---
# 前言
   网上搜的搞不懂，记录一种自己的笨方案，代码部分涉及es6，ui渲染没有贴出来
# sku定义
   SKU=Stock Keeping Unit（库存量单位）。即库存进出计量的基本单元，可以是以件，盒，托盘等为单位。SKU这是对于大型连锁超市DC（配送中心）物流管理的一个必要的方法。现在已经被引申为产品统一编号的简称，每种产品均对应有唯一的SKU号
# 数据库设计
  + 这个设计跟网上的设计有所不同，网上是用id表示唯一性的，但是这里的id不能用于sku计算
  + mall_goods_attr_key存放的是商品的规格组，比如某咖啡有颜色，尺码等规格组
  + mall_goods_attr_val存放的是商品规格组的规格值，比如某咖啡的颜色规格组有红色，白色，黑色等规格值
  + mall_goods_attr_sku存放的是某个具体的且有库存的sku信息，并且本方案是由具体的sku来决定自己的图片，没有图片的sku或者当没有命中sku时，显示商品默认图片
  ![](SKU选择算法/1.png)
  ![](SKU选择算法/2.png)
  ![](SKU选择算法/3.png)
# 接口返回数据
   sku表数据原样返回
   key和val表数据进行了整合，每一条表示一个规格组，vals表示他有哪些规格值，key，val都是按照序号排序过的
   ![](SKU选择算法/4.png)
# 计算类
  ## 说明 select_index 之前表示 当此选择的项下标，传null则代表取消勾选,后来改成直接传规格值文字了
``` js
  import _cloneDeep from 'lodash/cloneDeep';
export default class SkuLogic{
    dealImage(goods_list){
         for (let index = 0; index < goods_list.length; index++) {
            if(goods_list[index].selectSku!=null&&goods_list[index].selectSku.image!=''){
                goods_list[index].path=goods_list[index].selectSku.image;
                goods_list[index].sm_path=goods_list[index].selectSku.image;
            }
         }
         return goods_list;
    }
    initGoodsInfo(goods_info){
        goods_info.sku=this.initSkus(goods_info.sku,goods_info.skuKeyVals);
        let {selectSku,skuSpecs,selectSkuTips}=this.initSkuSpecs(goods_info.sku,goods_info.skuKeyVals);
        goods_info.totalStock=this.calcTotalStock(goods_info.sku)
        goods_info.selectSku=selectSku
        goods_info.skuSpecs=skuSpecs
        goods_info.selectSkuTips=selectSkuTips
        if(goods_info.skuSpecs.length==0
            &&goods_info.sku.length==1
            &&goods_info.selectSku
            &&goods_info.selectSku.stock<=0){
            goods_info.num=0
        }
        return goods_info;
    }
    get_key_path(skuSpecs) {
        if(skuSpecs&&skuSpecs.length>0){
            let groupName_arr=[];
            for (let index = 0; index < skuSpecs.length; index++) {
                let groupName=skuSpecs[index].groupName||skuSpecs[index].name
                 groupName_arr.push(groupName)
            }
           return groupName_arr.join('|')
        }else{
            return '';
        }
    }
    initSkus(skus,skuKeyVals){
        if(skus&&skus.length>0){
            for (let index = 0; index < skus.length; index++) {
                skus[index].price=parseFloat(skus[index].price||0)
                skus[index].discount_price=skus[index].discount_price||skus[index].price;//没填就是原价
                skus[index].discount_price=parseFloat(skus[index].discount_price)
                skus[index].stock=parseFloat(skus[index].stock||0)
                skus[index].attr_path=skus[index].attr_path||''
                skus[index].sku_key_path=this.get_key_path(skuKeyVals);
                skus[index].sku_val_path=skus[index].attr_path
                skus[index].image=skus[index].image||''
            }
        }
        return skus;
    }
    //获取sku的规格组
    initSkuSpecs(skus,skuKeyVals) {
        let  skuSpecs=[];
        let  selectSku=null;
        if(skuKeyVals&&skuKeyVals.length>0)
        {
            let select_able_ranges=init_select_able_ranges(skuKeyVals);//每组可选范围
            select_able_ranges= init_ranges_by_stock(skus,select_able_ranges);
            if(skuKeyVals&&skuKeyVals.length>0){
                for (let index = 0; index < skuKeyVals.length; index++) {
                    let vals=(skuKeyVals[index]['vals']||'').split('|');
                    skuSpecs[index]=
                    {
                        groupName:skuKeyVals[index]['name'],
                        spec_list:vals,
                        select_index:null,
                        //交集
                        select_able_range:select_able_ranges[index]
                    }; 
                }
            }
        }
        selectSku= this.calcSelectSku(skus,skuSpecs);
        let selectSkuTips=this.calcSelectSkuTips(selectSku,skuSpecs,skus);
        return {selectSku,skuSpecs,selectSkuTips};
    }

    /**
     * 重新计算sku规格信息 
     * @param {*} skus 数据库拿到的sku数据
     * @param {*} skuKeyVals 数据库拿到的skuKeyVals数据
     * @param {*} skuSpecs 带有选中信息的sku结构
     * @param {*} group_index 当此选择的组下标
     * @param {*} select_index  当此选择的项下标，传null则代表取消勾选
     */
    calcSkuSpecs(skus,skuKeyVals,skuSpecs,group_index,select_index,_selectSku) {
        let  selectSku=null;
        let checkSpec_arr=[];//已经选择过的sku规格
        if(skuSpecs[group_index].select_able_range.find(val=>val== select_index)){
            //只响应可选的项
            skuSpecs[group_index].select_index=skuSpecs[group_index].select_index==select_index?null:select_index;//前后相等表示取消选择
            let select_able_ranges=init_select_able_ranges(skuKeyVals);//每组可选范围
            select_able_ranges= init_ranges_by_stock(skus,select_able_ranges);
            if(skus&&skus.length>0){
                //模拟手动选择过程
                skuSpecs.map((skuSpec,index)=>{
                    if(skuSpec.select_index!=null){
                      let {select_able_ranges2,checkSpec_arr2}=checkSpec(skus,skuSpecs,select_able_ranges,index,skuSpec.select_index,checkSpec_arr);
                      select_able_ranges=select_able_ranges2;
                      checkSpec_arr=checkSpec_arr2;
                    }
                })
                skuSpecs= skuSpecs.map((skuSpec,index)=>{
                    skuSpec.select_able_range=select_able_ranges[index]; 
                    return skuSpec;
                })
            }
            selectSku=this.calcSelectSku(skus,skuSpecs);
        }else{
            selectSku=_selectSku;
        }
        let selectSkuTips=this.calcSelectSkuTips(selectSku,skuSpecs,skus);
        return {selectSku,skuSpecs:_cloneDeep(skuSpecs),selectSkuTips};
    }
    calcSelectSkuTips(selectSku,skuSpecs,skus){
        if(!skus||skus.length==0){
            return '未设置规格'
        }
        if(selectSku){
            if(selectSku['attr_path']||''!=""){
                let attrs = (selectSku['attr_path']||'').split('|');
                return '已选 "'+attrs.join('","')+'"';
            }
            else{
                return ''
            }
        }else{
            
            let unSelect=[];
            for (let index = 0; index < skuSpecs.length; index++) {
                if(skuSpecs[index].select_index==null){
                    unSelect.push(skuSpecs[index].groupName);
                }
            }
            return '请选择 "'+unSelect.join('","')+'"';
        }
    }
    /**
     * 计算选择了哪个sku
     * @param {*} skus 
     * @param {*} skuSpecs 
     */
    calcSelectSku(skus,skuSpecs){
        let  selectSku=null;
        let  path_now=[];
        if(skuSpecs.length==0||skus&&skus.length==1||(skus.length==1)){//&&skus[0]['attr_path']==''
            selectSku=skus[0]
        }else{
            for (let index = 0; index < skuSpecs.length; index++) {
                if(skuSpecs[index].select_index!=null){
                    path_now.push(skuSpecs[index].select_index)
                }
            }
            let path_str= path_now.join("|")
            let sku_now= skus.find(sku=>(sku['attr_path']||'')==path_str)
            if(sku_now){
                selectSku=sku_now
            }
        }
        return selectSku;
    }
    /** sku总库存 */
    calcTotalStock(skus){
         let stock=0;
         for (let index = 0; index < skus.length; index++) {
            stock+=parseFloat(skus[index].stock);
         }
         return stock;
    }
}
    /**
     * 每次计算选择的某一组对当前select_able_ranges的影响
     * @param {*} skus 
     * @param {*} skuSpecs 
     * @param {*} select_able_ranges 
     * @param {*} group_index 
     * @param {*} select_text 
     * @returns select_able_ranges2 被影响后的select_able_ranges
     */
    function checkSpec(skus,skuSpecs,select_able_ranges,group_index,select_text,checkSpec_arr2){
        let select_able_ranges2=[];//每组可选范围
        //let select_text=select_text
        let select_text_arr=[];
        checkSpec_arr2.push(skuSpecs[group_index]);
        for (let index = 0; index < checkSpec_arr2.length; index++) {
            select_text_arr.push(checkSpec_arr2[index].select_index) ;
        }
        let select_able_specOne=[];//重新拿到有库存的规格，用于过滤未选的sku规格
        skus.map((sku)=>{
            if(parseFloat(sku['stock'])>0&&isContained((sku['attr_path']||'').split('|'),select_text_arr)){
                let attrs = (sku['attr_path']||'').split('|');
                select_able_specOne = Array.from(new Set([...select_able_specOne, ...attrs])); // 并集
            }
        })
        for (let index = 0; index < select_able_ranges.length; index++) {
            let _i=select_text_arr.findIndex(text=>text==skuSpecs[index].select_index);
            if(skuSpecs[index].select_index!=null&&_i>-1){
                //已选的sku规格，用除了自己之外的已选sku规格来决定他自己哪些能选
               let select_text_arr2=select_text_arr.filter(text=>text!=skuSpecs[index].select_index);
                let select_able_specOne2=[];
                skus.map((sku)=>{
                    if(parseFloat(sku['stock'])>0&&isContained((sku['attr_path']||'').split('|'),select_text_arr2)){
                        let attrs = (sku['attr_path']||'').split('|');
                        select_able_specOne2 = Array.from(new Set([...select_able_specOne2, ...attrs])); // 并集
                    }
                })
                select_able_ranges2[index]=Array.from(new Set([...select_able_ranges[index]].filter(x => new Set(select_able_specOne2).has(x))))

            }else{
                
                select_able_ranges2[index]=Array.from(new Set([...select_able_ranges[index]].filter(x => new Set(select_able_specOne).has(x))))
            }
        }
        return {select_able_ranges2,checkSpec_arr2}

    }
    //是否被包含,是返回true,不是返回false
  function  isContained (a, b){
        if(!(a instanceof Array) || !(b instanceof Array)) return false;
        if(a.length < b.length) return false;
        var aStr = a.toString();
        for(var i = 0, len = b.length; i < len; i++){
        if(aStr.indexOf(b[i]) == -1) return false;
        }
        return true;
   }
    /**
    * 初始化 select_able_ranges
    * @param {*} skuKeyVals 
    */
   function init_select_able_ranges(skuKeyVals){
        let select_able_ranges=[];//每组可选范围
        if(skuKeyVals&&skuKeyVals.length>0){
            for (let index = 0; index < skuKeyVals.length; index++) {
                let vals=(skuKeyVals[index]['vals']||'').split('|');
                select_able_ranges[index]=vals;
            }
        }
        return select_able_ranges;
        }
    /**
    * 计算库存对select_able_ranges的影响
    * @param {*} skus 
    * @param {*} select_able_ranges 
    */
   function init_ranges_by_stock(skus,select_able_ranges) {
        let select_able_specs = [];
        if (skus && skus.length > 0) {
            skus.map((sku) => {
                if (parseFloat(sku['stock'] ) > 0) {
                    let attrs = (sku['attr_path'] || '').split('|');
                    select_able_specs = Array.from(new Set([...select_able_specs, ...attrs])); // 并集
                }
            });
        }
        for (let index = 0; index < select_able_ranges.length; index++) {
            select_able_ranges[index]= Array.from(new Set([...select_able_specs].filter(x =>new Set( select_able_ranges[index]).has(x))))
        }
        return select_able_ranges;
    }
```

# 字段定义
  + 拿到商品信息GoodsInfo,即3步骤的数据结构，调用initGoodsInfo进行初始化`GoodsInfo=skuLogic.initGoodsInfo(GoodsInfo);`这之后，GoodsInfo里会多出三个数据结构
  +   `selectSku` 命中的sku，没有命中时是null
  +  `selectSkuTips` 选择提示，没有命中时，提示选择余下的规格组，命中后提示选了哪些规格值
  +  `skuSpecs`用于渲染界面，也用于计算sku，每一项表示一个规格组
  +  `select_able_ranges`表示可选的规格值
  + `select_index`表示选中的规格值，null表示未选择
  +  `spec_list`表示所有规格值
# 大致思路 
  + 有四种类型的规格值
     + 不可选
     + 在已选择列可选且已选中的规格值
     + 在未选择列的可选规格值
     + 在已选择列其他可选规格值
  + 初始化的时候，查询sku列表能知道哪些是永远不可选的，哪些是可选的
  + 当做一次选择的时候
    + 2类型的规格值是知道的，你选了哪些规格值就是哪些，
    + 3类型的规格值确定，由包含已选路径的sku来确定
    + 4类型的规格值确定，当你要确定某一个已选列的其他可选规格值的时候，已选路径去掉当前列已选规格值，作为新的已选路径，由包含新的已选路径的sku来确定4类型的点
    + 其他的就是1类型的规格值
    + 四种类型的规格值构成skuSpecs
    + 已选路径能确定是否命中sku


