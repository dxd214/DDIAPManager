## 前言

基于苹果内置付费（IAP）的Block的封装。首先得去苹果开发者网站配置好证书，需要注意的是只能使用具体名称的APP ID  不能使用含有通配符（*）的任何ID，否则测试不成功。


##如何使用
（1）根据配置itunes connect 时候留下的productID 查询商品信息，返回商品信息

```
- (void)requestProducts:(NSArray *)productsID
                success:(DDIAPProductSuccess)successBlock
                failure:(DDIAPFailure)failureBlock

```


（2）根据返回的商品信息，购买商品。

```

- (void)addPayment:(SKProduct *)product
          quantity:(NSInteger)quantity
           success:(DDIAPRequestSuccess)successBlock
           failure:(DDIAPFailure)failureBlock;
```




## 作者

微博： 	[@小木头](http://weibo.com/329096966)

Blog:	 [www.liuchendi.com](www.liuchendi.com)


