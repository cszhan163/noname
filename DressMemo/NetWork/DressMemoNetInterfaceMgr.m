//
//  DressMemoNetInterfaceMgr.m
//  DressMemo
//
//  Created by  on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DressMemoNetInterfaceMgr.h"
#import "ZCSNetClient.h"
#import "ZCSNotficationMgr.h"
#import "NTESMBAPIStatusUpdateImage.h"
#import "RequestCfg.h"
#import "DBManage.h"
#define ASI_ENGINE 
#ifdef ASI_ENGINE
#import "ZCSASIRequest.h"
#endif

static NSString *kNEFYJsonKeyResult = @"ret";
//static NSString *kNEFYJsonKeyResult = @"reault";
static NSString *kNEFYJsonResultOK = @"success";
static NSString *kNEFYJsonData     = @"info";

//#define kRequestApiRoot @"http://www.taskcity.com/login"
#define kRequestApiRoot @"http://api.iclub7.com"

static DressMemoNetInterfaceMgr *sharedInstance = nil;
@interface DressMemoNetInterfaceMgr()
@property(nonatomic,retain)NSDictionary *requestResourceDict;
@property(nonatomic,retain)NSMutableArray *queueRequestsArr;
@property(nonatomic,retain)NSMutableDictionary *requestsWorkingDict;
@property(nonatomic,assign)BOOL isLogin;
@property(nonatomic,assign)BOOL isLoginLoading;
@property(nonatomic,retain)NSString *gToken;
@end
@implementation DressMemoNetInterfaceMgr
@synthesize requestResourceDict;
@synthesize requestsWorkingDict;
@synthesize queueRequestsArr;
@synthesize  isLogin;
@synthesize  gToken;
@synthesize isLoginLoading;
+(id)getSingleTone
{
	@synchronized(self)
    {
		if(sharedInstance == nil){
			sharedInstance = [[self alloc]initInterfaceData];
		}
	}
	return sharedInstance;
}
-(id)initInterfaceData
{
    /*
     /user/register
     /user/update
     /user/login
     /memo/uploadpic
     /memo/add
     /memo/getOccasions
     /memo/getEmotions
     /memo/getCountries
     /memo/getCats
     */
    if(self = [super init])
    {
        requestResourceDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                               @"/user/login"    ,     @"login",
                               @"/user/register",      @"register",
                               @"/user/update",        @"update",
                               @"/user/forgetpwd",     @"forgetpwd",
                               @"/memo/add",           @"add",
                               @"/memo/getOccasions",  @"getOccasions",
                               @"/memo/getEmotions",   @"getEmotions",
                               @"/memo/getCountries",  @"getCountries",
                               @"/memo/getCats",       @"getCats",
                               @"/memo/uploadpic",     @"uploadpic",
                               
                               nil];
        
        requestsWorkingDict =[[NSMutableDictionary alloc]init];
        queueRequestsArr = [[NSMutableArray alloc]init];
        //otherRequestsWorkingDict = [[NSMutableDictionary alloc]init];
        [self addObservers];
    }
    return  self;
    
}
-(void)addObservers
{
    [ZCSNotficationMgr addObserver:self call:@selector(startNetWork:) msgName:kZCSNetWorkStart];
    [ZCSNotficationMgr addObserver:self call:@selector(didGetRespondDataAsMSG:) msgName:HTTP_REQUEST_COMPLETE];
    [ZCSNotficationMgr addObserver:self call:@selector(didGetRespondErrorAsMSG:) msgName:HTTP_REQUEST_ERROR];
}
#pragma mark -
#pragma mark msg 
-(void)startNetWork:(NSNotification*)ntf
{   
    /*
    NSString *key = [ntf object];
    [self startAnRequestByResKey:key needLogIn:<#(BOOL)#> withParam:<#(NSDictionary *)#> withMethod:<#(NSString *)#>
    */
}
-(id)startAnRequestByResKey:(NSString*)resKey needLogIn:(BOOL)needLogin withParam:(NSDictionary*)params withMethod:(NSString*)method withData:(BOOL)hasData
{
    //if the don't log in ,we need login first
    //gToken = @"87ce6b415e2e316ec1be2e6fc6f034c4";
     if (needLogin &&!isLogin && ![resKey isEqualToString:@"login"]&&1)
     {
         //添加登录request，保证先后执行
         //return  [self startAnRequestByResKey:@"login" withParam:params withMethod:method];
         
         
         ZCSNetClient *followClient = [self ComposeAnRequestByResKey:resKey  withParam:params withMethod:method withData:hasData];
         if(!isLoginLoading)
         {
             NSMutableDictionary * paramsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       //@"login",@"method",		  
                                                       @"cszhan@163.com",@"email",
                                                       //@""		 ,@"nameErrorFocus",
                                                       @"123456",@"pass",
                                                       //@"",@"passwordErrorFocus",
                                                       //[params objectForKey:@"randcode"],@"randCode",
                                                       //@"",@"randErrorFocus",
                                                       //@"iphone",@"platform",
                                                       nil];
             ZCSNetClient *loginClient = [self startAnRequestByResKey:@"login" 
                                                            withParam:paramsDictionary 
                                                           withMethod:@"POST"
                                                             withData:NO];
             //loginClient.resourceKey = @"login";
             isLoginLoading = YES;
             loginClient.followRequest = followClient;
         }
         [queueRequestsArr addObject:followClient];
         //we can releas it 
         [followClient release];
         return followClient;
         
     }
    //we need to add the 
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if(needLogin && ![resKey isEqualToString:@"login"]&& gToken)
    {
        [finalParams  setValue:gToken forKey:@"token"];
    }
    //UIDevice
    return [self startAnRequestByResKey:resKey withParam:finalParams withMethod:method withData:hasData];
}
-(id)startAnRequestByResKey:(NSString*)resKey needLogIn:(BOOL)needLogin withParam:(NSDictionary*)params withMethod:(NSString*)method withData:(BOOL)hasData withFileName:(NSString*)fileName
{

        //if the don't log in ,we need login first
        //gToken = @"87ce6b415e2e316ec1be2e6fc6f034c4";
        if (needLogin &&!isLogin && ![resKey isEqualToString:@"login"]&&1)
        {
            //添加登录request，保证先后执行
            //return  [self startAnRequestByResKey:@"login" withParam:params withMethod:method];
            
            
            ZCSNetClient *followClient = [self ComposeAnRequestByResKey:resKey  withParam:params withMethod:method withData:hasData withFileData:fileName];
            if(!isLoginLoading)
            {
                NSMutableDictionary * paramsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                          //@"login",@"method",		  
                                                          @"cszhan@163.com",@"email",
                                                          //@""		 ,@"nameErrorFocus",
                                                          @"123456",@"pass",
                                                          //@"",@"passwordErrorFocus",
                                                          //[params objectForKey:@"randcode"],@"randCode",
                                                          //@"",@"randErrorFocus",
                                                          //@"iphone",@"platform",
                                                          nil];
                ZCSNetClient *loginClient = [self startAnRequestByResKey:@"login" 
                                                               withParam:paramsDictionary 
                                                              withMethod:@"POST"
                                                                withData:NO];
                //loginClient.resourceKey = @"login";
                isLoginLoading = YES;
                loginClient.followRequest = followClient;
            }
            [queueRequestsArr addObject:followClient];
            
            return followClient;
            
        }
        //we need to add the 
        NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithDictionary:params];
        if(needLogin && ![resKey isEqualToString:@"login"]&& gToken)
        {
            [finalParams  setValue:gToken forKey:@"token"];
        }
        //UIDevice
    return [self startAnRequestByResKey:resKey withParam:finalParams withMethod:method withData:hasData withFileName:fileName];
    //}


}
-(id)startAnRequestByResKey:(NSString*)resKey withParam:(NSDictionary*)params withMethod:(NSString*)method withData:(BOOL)hasData withFileName:(NSString*)fileName
{
    ZCSNetClient *netClient = nil;
    netClient = [self ComposeAnRequestByResKey:resKey withParam:params withMethod:method withData:hasData];
    //netClient.requestKey = resKey;
    netClient.filePath = fileName;
    [self startRequest:netClient];
    [requestsWorkingDict setValue:netClient forKey:netClient.requestKey];
    [netClient autorelease];
    return netClient; 
    
}
-(id)startAnRequestByResKey:(NSString*)resKey withParam:(NSDictionary*)params withMethod:(NSString*)method withData:(BOOL)hasData
{
    
    ZCSNetClient *netClient = nil;
    netClient = [self ComposeAnRequestByResKey:resKey withParam:params withMethod:method withData:hasData];
    netClient.requestKey = resKey;
    [self startRequest:netClient];
    [requestsWorkingDict setValue:netClient forKey:netClient.requestKey];
    [netClient autorelease];
    return netClient;
}
-(id)ComposeAnRequestByResKey:(NSString*)resKey withParam:(NSDictionary*)params withMethod:(NSString*)method
{

    NSString *resourcePath = [requestResourceDict objectForKey:resKey];
    assert(resourcePath);
    NSString *requestUrl  = [NSString stringWithFormat:@"%@%@",kRequestApiRoot,resourcePath];
    
    NSString *requestKey = [NSString generateNonce];
    
    
    ZCSNetClient *netClient = [[ZCSNetClient alloc]initWithDelegate:self withAction:@selector(didGetrespondData:)];
    netClient.requestKey = requestKey;
    netClient.resourceKey = resKey;
    //[requestsMapDict setObject:netClient forKey:requestKey];
    [netClient composeRequsestByUrl:requestUrl 
                          withParam:params 
                         withMethod:method];
    return netClient;
}
-(id)ComposeAnRequestByResKey:(NSString*)resKey withParam:(NSDictionary *)params withMethod:(NSString *)method withData:(BOOL)hasData
{
    ZCSNetClient * netClient = [self ComposeAnRequestByResKey:resKey withParam:params withMethod:method];
    netClient.isPostData = hasData;
    return netClient;
}
-(id)ComposeAnRequestByResKey:(NSString*)resKey withParam:(NSDictionary *)params withMethod:(NSString *)method withData:(BOOL)hasData withFileData:(NSString*)fileName
{
    ZCSNetClient * netClient = [self ComposeAnRequestByResKey:resKey withParam:params withMethod:method];
    netClient.isPostData = hasData;
    netClient.filePath = fileName;
    return netClient;
}
-(void)startRequest:(ZCSNetClient*)client
{
#ifdef  ASI_ENGINE
    if([client.resourceKey isEqualToString:@"uploadpic"])
    {
        NTESMBRequest *newRequest = [self useASIRequest:client.filePath withRequestKey:client.requestKey];
        //newRequest.parentObj = client;
        client.request = nil;
        client.otherRequest = newRequest;
        [ZCSNotficationMgr postMSG:kZCSNetWorkStart obj:client];
        return;
    }
#endif
    if([client.resourceKey isEqualToString:@"login"])
        [client startRequest:YES];
    else 
    {
        [client startRequest:YES];
    }
    [ZCSNotficationMgr postMSG:kZCSNetWorkStart obj:client]; 
}

-(ZCSASIRequest*)useASIRequest:(NSString*)filePath withRequestKey:(NSString*)requestKey
{
	//NSString *filePath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"png"];
    NTESMBAPIStatusUpdateImage *updateStatus = [[NTESMBAPIStatusUpdateImage alloc]initUpdateImageRequestWithFilePath:filePath withtoken:self.gToken];
    updateStatus.objId = requestKey;
    ZCSASIRequest *request = [[NTESMBServer getInstance] addRequest:updateStatus];
    //[requestsWorkingDict setValue:request forKey:requestKey];
    return request;
}
-(ZCSASIRequest*)useASIRequest:(NSDictionary*)param withFilePath:(NSString*)filePath withRequestKey:(NSString*)requestKey
{
	//NSString *filePath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"png"];
    NTESMBAPIStatusUpdateImage *updateStatus = [[NTESMBAPIStatusUpdateImage alloc]initUpdateImageRequestWithFilePath:filePath withtoken:self.gToken];
    updateStatus.objId = requestKey;
    //updateStatus.postArguments = 
    ZCSASIRequest *request = [[NTESMBServer getInstance] addRequest:updateStatus];
    //[requestsWorkingDict setValue:request forKey:requestKey];
    return request;
}
-(void)getRequestInstanceByKey:(NSString*)requestKey
{

}
#pragma mark -
#pragma mark message respond
-(void)didGetRespondDataAsMSG:(NSNotification*)ntf
{
    id result = [ntf object];
    NSString *requestKey = nil;
    if([result isKindOfClass:[NTESMBRequest class]])
        requestKey = [result objId];
    ZCSNetClient  *client = [requestsWorkingDict valueForKey:requestKey];
    if([client.resourceKey isEqualToString:@"uploadpic"])
    {
         NSData *data = [result receiveData];
        //this for upload Image
        if([result isKindOfClass:[NTESMBAPIStatusUpdateImage class]])
        {
            
            NSString *resultStr = [[NSString alloc]initWithData:data encoding:client.respDataEncode];
            NE_LOG(@"final:%@",resultStr);
            NSDictionary *restData = [resultStr JSONValue];
            NSString *ret = [restData objectForKey:kNEFYJsonKeyResult];
            if(![ret isEqualToString:kNEFYJsonResultOK])
            {
                
                [self checkServerRespondDataError:client withResult:restData];
                return ;
            }
            else
            { 
                DBManage *dbMgr = [DBManage getSingleTone];
                NSDictionary *picIdDict = [restData objectForKey:kNEFYJsonData];
                NE_LOG(@"%@",picIdDict);
                [dbMgr addUploadpicObject:picIdDict withRequestKey:client.requestKey];
            }
            [resultStr release];
            NSDictionary *ntfData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     restData,@"data",
                                     client ,@"request",
                                     nil];
            
            [ZCSNotficationMgr  postMSG:kZCSNetWorkOK obj:ntfData];
        }
        else 
        {
          [self checkRightRequest:client withData:data];  
        }
        
        
    }
   
    
    /*
    [ZCSNotficationMgr postMSG:kZCSNetWorkOK obj:client];
    [requestsWorkingDict removeObjectForKey:requestKey];
    */
}
-(void)didGetRespondErrorAsMSG:(NSNotification*)ntf
{
    NSLog(@"ASIRequestFailed");
#if 0
    id result = [ntf object];
    NSString *requestKey = nil;
    if([result isKindOfClass:[NTESMBRequest class]])
        requestKey = [result objId];
    ZCSNetClient  *client = [requestsWorkingDict valueForKey:requestKey];
/*
    if([client.resourceKey isEqualToString:@"uploadpic"])
    {
        
    }
*/
    NSData *data = [result receiveData];
    [self checkRequestDomainError:client withData:data];
#endif

    
}
#pragma mark -
#pragma mark delegate respond
-(void)didGetrespondData:(id)data
{
    NSDictionary *resultDict = (NSDictionary*)data;
    ZCSNetClient *request = [resultDict objectForKey:@"sender"];
    if([request.requestKey isEqualToString:@"login"])
    {
        isLoginLoading = NO;
    }
    id resultData = [resultDict objectForKey:@"data"];
   
    if([resultData isKindOfClass:[NSError class]])
    {
        NE_LOG(@"request:%@,net work request error",request.requestKey);
        if([request.requestKey isEqualToString:@"login"])
        {
            [queueRequestsArr  removeAllObjects];
        }
        [self checkRequestDomainError:request withData:resultData];
        //[ZCSNotficationMgr postMSG:kZCSNetWorkRequestFailed obj:resultData];
    }
    else
    {
        NE_LOG(@"request:%@,result:%@",request.requestKey,[[NSString alloc]initWithData:resultData encoding:request.respDataEncode]);
        [self checkRightRequest:request withData:resultData];
       
        
    }
    [requestsWorkingDict removeObjectForKey:request.requestKey];
    //[request release];
    
    
}
-(void)checkRightRequest:(ZCSNetClient*)request withData:(id)data
{
    NSString *resultStr = [[NSString alloc]initWithData:data encoding:request.respDataEncode];
    NE_LOG(@"final:%@",resultStr);
    NSDictionary *restData = [resultStr JSONValue];
    NSString *ret = [restData objectForKey:kNEFYJsonKeyResult];
    if(![ret isEqualToString:kNEFYJsonResultOK])
    {
    
        [self checkServerRespondDataError:request withResult:restData];
        return ;
    }
    
    if(request.followRequest!=nil &&[request.resourceKey isEqualToString:@"login"])
    {
        //if login ok ,
        
        NSString *token = [[restData objectForKey:@"info"]objectForKey:@"token"];
        
        if(token)
        {
            self.gToken = token;
            isLogin = YES;
        }
        @synchronized(self)
        {
            int requestCount = [queueRequestsArr count];
            for(int i = 0;i<requestCount;i++)
            {
                
                ZCSNetClient *client = [queueRequestsArr objectAtIndex:i];
                NSDictionary *addParam = [NSDictionary dictionaryWithObject:self.gToken forKey:@"token"];
                [client reComposetRequestAddParam:addParam];
                //sleep(10);
                [self startRequest:client];
                [requestsWorkingDict setObject:client forKey:client.requestKey];
                //[queueRequestsArr removeObject:client];
            }
            [queueRequestsArr removeAllObjects];
        }
    }
    else 
    {
        NSDictionary *ntfData = [NSDictionary dictionaryWithObjectsAndKeys:
                                restData,@"data",
                                 request ,@"request",
                                 nil];
        
        [ZCSNotficationMgr  postMSG:kZCSNetWorkOK obj:ntfData];
    
    }

}
#pragma mark -
#pragma mark request domain error
-(void)checkRequestDomainError:(ZCSNetClient*)request withData:(NSData*)data
{
    isLogin = NO;
    if(request.followRequest!=nil &&[request.resourceKey isEqualToString:@"login"])
    {
       
    }
    else 
    {
    
    }
    [ZCSNotficationMgr postMSG:kZCSNetWorkRequestFailed obj:data]; 
}
#pragma mark -
#pragma mark server respond data error
-(void)checkServerRespondDataError:(ZCSNetClient*)request withResult:(NSDictionary*)dataDict
{
    NE_LOG(@"error info :%@",[dataDict description]);
    [ZCSNotficationMgr postMSG:kZCSNetWorkRespondFailed obj:dataDict];
}
-(void)cancelRequest:(ZCSNetClient*)request
{
    NSString *requestKey = request.requestKey;
    ZCSNetClient *netClient = [requestsWorkingDict objectForKey:requestKey];
    [netClient cancelRequest];
    [requestsWorkingDict removeObjectForKey:requestKey];
}
-(void)dealloc{
    [ZCSNotficationMgr removeObserver:self];
    self.requestsWorkingDict = nil;
    self.requestResourceDict = nil;
    self.queueRequestsArr = nil;
    //self.otherRequestsWorkingDict = nil;
    [super dealloc];
}
@end
