//
//  DDIAPManager.m
//  DDSlideViewControllerDemo
//
//  Created by lovelydd on 14/11/6.
//  Copyright (c) 2014年 lovelydd. All rights reserved.
//

#import "DDIAPManager.h"

static DDIAPManager *transactionManager;

#define Add_Product_Failure_block(message,failureType) self.failureBlock(message,failureType);

@interface DDIAPManager()<SKProductsRequestDelegate>


@property(nonatomic,copy)DDIAPProductSuccess productSuccessBlock;
@property(nonatomic,copy)DDIAPRequestSuccess requestSuccessBlock;
@property(nonatomic,copy)DDIAPFailure       failureBlock;

@end

@implementation DDIAPManager


- (void)requestProducts:(NSArray *)productsID
                success:(DDIAPProductSuccess)successBlock
                failure:(DDIAPFailure)failureBlock
{
    if (![self validPurches]) {
        
        failureBlock(@"请求失败,用户禁止应用内付费购买.",DDIAPInvalidPurchase);
    }
    
    if (self.failureBlock) {
        self.failureBlock = nil;
    }
    
    
    self.productSuccessBlock = successBlock;
    self.failureBlock = failureBlock;
    
    //事先准备好productID,可以从服务器获取或者本地存储
    NSSet * set = [NSSet setWithArray:productsID];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}


- (void)addPayment:(SKProduct *)product
          quantity:(NSInteger)quantity
           success:(DDIAPRequestSuccess)successBlock
           failure:(DDIAPFailure)failureBlock;
{
    if (self.failureBlock) {
        self.failureBlock = nil;
    }
    
    self.requestSuccessBlock = successBlock;
    self.failureBlock = failureBlock;
    
    
    SKMutablePayment *payments = [SKMutablePayment paymentWithProduct:product];
    payments.quantity = quantity;
    [[SKPaymentQueue defaultQueue] addPayment:payments];
}


#pragma mark -
#pragma mark - SKProductsRequestDelegate

/*
 *
 *  获取产品的信息
 *
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    
    //失败
    if (myProduct.count == 0) {
        Add_Product_Failure_block(@"没有查询到购买产品信息", DDIAPProductNotFount)
        NSLog(@"无法获取产品信息，购买失败。");
        return;
    }
    self.productSuccessBlock(myProduct);
}



/*
 *
 *  返回服务器交易的结果
 *
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"交易完成 :transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                NSLog(@"交易失败");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                NSLog(@"恢复已购买过的商品");
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //购买中
                NSLog(@"交易中");
                break;
            default:
                break;
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSString * productIdentifier = transaction.payment.productIdentifier;
    NSString * receipt = [transaction.transactionReceipt base64Encoding];
    
    if ([productIdentifier length] > 0) {
        
        //TODO: 向自己的服务器验证购买凭证
        
        
        self.requestSuccessBlock(receipt);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}


- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if(transaction.error.code != SKErrorPaymentCancelled) {
        Add_Product_Failure_block(@"交易失败",DDIAPPurchaseFailure)
        
    } else {
        Add_Product_Failure_block(@"用户取消交易",DDIAPUserCancelPurchase)
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//对于非消耗品重复购买
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    Add_Product_Failure_block(@"已经拥有了该商品",DDIAPRestorePurchase);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

/*
 *
 * 判断用户是否允许应用内付费购买
 *
 */
- (BOOL)validPurches
{
    if ([SKPaymentQueue canMakePayments]) {
        return YES;
    }
    
    return NO;
}


+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        transactionManager = [[DDIAPManager alloc] init];
    });
    
    return transactionManager;
}

@end
