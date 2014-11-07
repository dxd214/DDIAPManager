//
//  DDIAPManager.h
//  DDSlideViewControllerDemo
//
//  Created by lovelydd on 14/11/6.
//  Copyright (c) 2014年 lovelydd. All rights reserved.

//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger, DDIAPManagerFailureType){
    
    DDIAPInvalidPurchase    = 0,    //禁止应用内付费购买
    DDIAPProductNotFount    = 1,    //产品信息获取失败
    DDIAPPurchaseFailure    = 2,    //交易失败
    DDIAPUserCancelPurchase = 3,    //用户取消购买
    DDIAPRestorePurchase    = 4,    //对于非消耗品重复购买。
};

typedef void(^DDIAPProductSuccess)(NSArray *products);   //产品查询成功结果
typedef void(^DDIAPRequestSuccess)(NSString * receipt); //成功后返回凭证

typedef void(^DDIAPFailure)(NSString *errorMessage,DDIAPManagerFailureType errorType);//IAP操作失败


@interface DDIAPManager : NSObject




+(instancetype)sharedInstance;

/*
 *
 * 查询产品的信息,查询成功后会返回商品信息
 *
 */
- (void)requestProducts:(NSArray *)products
                success:(DDIAPProductSuccess)successBlock
                failure:(DDIAPFailure)failureBlock;

/*
 *
 *  购买产品
 *
 */
- (void)addPayment:(SKProduct *)product
          quantity:(NSInteger)quantity
           success:(DDIAPRequestSuccess)successBlock
           failure:(DDIAPFailure)failureBlock;

@end