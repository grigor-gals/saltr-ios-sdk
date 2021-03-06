/*
 * @file
 * Saltr
 *
 * Copyright Teoken LLC. (c) 2014. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

#import "SLTSaltr.h"
#import "SLTFeature.h"
#import "SLTResource.h"
#import "SLTDeserializer.h"
#import "SLTExperiment.h"
#import "SLTLevelPack.h"
#import "SLTPartner.h"
#import "SLTDevice.h"
#import "SLTConfig.h"
#import "SLTError.h"

@interface SLTSaltr() {
    // @note No @b SLTRepository object is needed, as all the methods are static
//    SLTRepository* _repository;
    NSString* _saltrUserId;
    BOOL _isLoading;
    BOOL _connected;
    BOOL _isInDevMode;
    SLTPartner* _partner;
    SLTDeserializer* _deserializer;
    SLTDevice* _device;
}
@end

@implementation SLTSaltr

@synthesize instanceKey = _instanceKey;
@synthesize enableCache;
@synthesize appVersion;
@synthesize ready;
@synthesize features=_features;
@synthesize levelPacks=_levelPacks;
@synthesize experiments=_experiments;
@synthesize saltrRequestDelegate;
@synthesize connected=_connected;

-(id) initUniqueInstance
{
    self = [super init];
    if (self) {
        _deserializer = [SLTDeserializer new];
        _features = [NSMutableDictionary new];
        _isLoading = NO;
        _connected = NO;
        _isInDevMode = YES;
    }
    return self;
}

-(void) setInstanceKey:(NSString *)instanceKey
{
    _instanceKey = instanceKey;
}

+(id) saltrWithInstanceKey:(NSString *)instanceKey andCacheEnabled:(BOOL)enableCache
{
    [SLTSaltr sharedInstance].instanceKey = instanceKey;
    [SLTSaltr sharedInstance].enableCache = enableCache;
    return [SLTSaltr sharedInstance];
}

+(instancetype) sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[super alloc] initUniqueInstance];
    });
    
    // returns the same object each time
    return _sharedObject;
}

-(SLTFeature *) featureForToken :(NSString *)token {
    return [_features objectForKey:token];
}

-(void) setupPartnerWithId:(NSString *)partnerId andPartnerType:(NSString *)partnerType {
    _partner = [[SLTPartner alloc] initWithPartnerId:partnerId andPartnerType:partnerType];
}

-(void) setupDeviceWithId:(NSString *)deviceId andDeviceType:(NSString *)deviceType {
    _device = [[SLTDevice alloc] initWithDeviceId:deviceId andDeviceType:deviceType];
}

-(void) importLevels:(NSString *)path {
    path = !path ? LEVEL_PACK_URL_PACKAGE : path;
    NSDictionary* applicationData = [SLTRepository objectFromApplication:path];
    _levelPacks = [_deserializer decodeLevelsFromData:applicationData];
}

-(void) defineFeatureWithToken:(NSString*)token andProperties:(NSDictionary *)properties {
    SLTFeature* feature = [_features objectForKey:token];
    if (nil == feature) {
        feature = [[SLTFeature alloc] initWithToken:token defaultProperties:properties andProperties:nil];
        [_features setValue:feature forKey:token];
    } else {
        feature.defaultProperties = properties;
    }
}

-(void) start {
    if (_isLoading) {
        return;
    }
    [self applyCachedFeatures];
    _isLoading = YES;
    _connected = NO;
    void (^appDataLoadFailedCallback)(SLTResource*) = ^(SLTResource* asset) {
        [asset dispose];
        [self loadAppDataFailHandlerWithErrorCode:GENERAL_ERROR_CODE andMessage:@"Could not connect to SALTR"];
    };
    void (^appDataLoadCompleteCallback)(SLTResource*) = ^(SLTResource* asset) {
        NSDictionary* data = asset.jsonData;
        NSDictionary* jsonData = [data objectForKey:@"responseData"];
        NSString* status = [data objectForKey:@"status"];
        assert(status);
        _isLoading = NO;
        if ([status isEqualToString:RESULT_SUCCEED]) {
            [SLTRepository cacheObject:APP_DATA_URL_CACHE version:@"0" object:jsonData];
            _connected = YES;
            [self loadAppDataSuccessHandler:jsonData];
        } else {
            [self loadAppDataFailHandlerWithErrorCode:[[jsonData objectForKey:@"errorCode"] integerValue]  andMessage:[jsonData objectForKey:@"errorMessage"]];
        }
        [asset dispose];
    };
    SLTResource* asset = [self createDataResource:appDataLoadCompleteCallback errorHandler:appDataLoadFailedCallback];
    [asset load];
}

-(void) loadLevelContentData:(SLTLevelPack*)levelPackStructure
                    levelStructure:(SLTLevel*)levelStructure andCacheEnabled:(BOOL)cacheEnabled {
    if (!cacheEnabled) {
        [self loadLevelContentDataFromSaltr:levelPackStructure levelData:levelStructure forceNoCache:YES];
        return;
    } else {
        //if there is no version change than load from cache
        NSString* cachedVersion = [self cachedLevelVersion:levelPackStructure andLevel:levelStructure];
        if (cachedVersion && [levelStructure.version isEqualToString:cachedVersion]) {
            NSDictionary* contentData = [self loadLevelContentDataFromCache:levelPackStructure andLevel:levelStructure];
            [self contentDataLoadSuccessCallback:levelStructure data:contentData];
        } else {
            [self loadLevelContentDataFromSaltr:levelPackStructure levelData:levelStructure forceNoCache:NO];
        }
    }
}

/// @todo The function below is commented out, as the corresponding one in ac3 is commented as well.
-(void) addUserPropertyWithNames:(NSArray *)propertyNames
                          values:(NSArray *)propertyValues
                   andOperations:(NSArray *)operations {
    
//    NSMutableDictionary* args = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_saltrUserId, @"saltId", nil];
//    NSMutableArray* properties = [NSMutableArray new];
//    for (NSInteger i = 0; i < [propertyNames count]; ++i) {
//        NSString* propertyName = [propertyNames objectAtIndex:i];
//        NSString* propertyValue = [propertyValues objectAtIndex:i];
//        NSString* operation = [operations objectAtIndex:i];
//        [properties addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:propertyValue, operation, nil], propertyName, nil]];
//    }
//    [args setObject:properties forKey:@"properties"];
//    [args setObject:_instanceKey forKey:@"instanceKey"];
//    
//    
//    NSError* error = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//    if (!error) {
//        NSString *jsonArguments = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonArguments = [jsonArguments stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

//        NSString* urlVars = [NSString stringWithFormat:@"?command=%@&arguments=%@", COMMAND_ADD_PROPERTY, jsonArguments];
//        
//        
//        SLTResourceURLTicket* ticket = [[SLTResourceURLTicket alloc] initWithURL:SALTR_API_URL andVariables:urlVars];
//        void (^addUserPropertySuccessHandler)(SLTResource *) = ^(SLTResource *resource) {
//            [resource dispose];
//        };
//        void (^addUserPropertyFailHandler)(SLTResource *) = ^(SLTResource *resource) {
//            [resource dispose];
//        };
//        SLTResource* resource = [[SLTResource alloc] initWithId:@"property" andTicket:ticket successHandler:addUserPropertySuccessHandler errorHandler:addUserPropertyFailHandler progressHandler:nil];
//        [resource load];
//    }
}

#pragma mark private functions

-(void) applyCachedFeatures {
    NSDictionary* cachedData = [SLTRepository objectFromCache:APP_DATA_URL_CACHE];
    NSDictionary* cachedFeatures = [_deserializer decodeFeaturesFromData:cachedData];
    for (NSString* token in [cachedFeatures allKeys]) {
        SLTFeature* saltrFeature = [cachedFeatures objectForKey:token];
        SLTFeature* defaultFeature = [_features objectForKey:token];
        if (defaultFeature) {
            saltrFeature.defaultProperties = defaultFeature.defaultProperties;
        }
        [_features setObject:saltrFeature forKey:token];
    }
}

-(SLTResource *)createDataResource:(void (^)(SLTResource *))appDataAssetLoadCompleteHandler errorHandler:(void (^)(SLTResource *))appDataAssetLoadErrorHandler {
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
    [args setObject:_instanceKey forKey:@"instanceKey"];
    if (_device) {
        [args setObject:[_device toDictionary] forKey:@"device"];
    }
    if (_partner) {
        [args setObject:[_partner toDictionary] forKey:@"partner"];
    }
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!error) {
        NSString *jsonArguments = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonArguments = [jsonArguments stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* urlVars = [NSString stringWithFormat:@"?command=%@&arguments=%@", COMMAND_APP_DATA, jsonArguments];
        
        SLTResourceURLTicket* ticket = [[SLTResourceURLTicket alloc] initWithURL:SALTR_API_URL andVariables:urlVars];
        SLTResource* resource = [[SLTResource alloc] initWithId:@"saltAppConfig" andTicket:ticket successHandler:appDataAssetLoadCompleteHandler errorHandler:appDataAssetLoadErrorHandler progressHandler:nil];
        return resource;
    }
    return nil;
}

-(void) loadAppDataSuccessHandler:(NSDictionary *)jsonData {
     _saltrUserId = [jsonData objectForKey:@"saltId"];
    _experiments = [_deserializer decodeExperimentsFromData:jsonData];
    _levelPacks = [_deserializer decodeLevelsFromData:jsonData];
    NSDictionary* saltrFeatures = [_deserializer decodeFeaturesFromData:jsonData];
    //merging with defaults...

    for (NSString* key in [saltrFeatures allKeys]) {
        SLTFeature* saltrFeature = [saltrFeatures objectForKey:key];
        SLTFeature* defaultFeature = [_features objectForKey:key];
        saltrFeature.defaultProperties = defaultFeature.defaultProperties;
        [_features setValue:saltrFeature forKey:key];
    }
    
    if ([saltrRequestDelegate respondsToSelector:@selector(didFinishGettingAppDataRequest)]) {
        [saltrRequestDelegate didFinishGettingAppDataRequest];
    }
    /// @todo the meaning of the boolean below is not clear.
    // The condition will be always true as the mentioned boolean never changes its value.
    if (_isInDevMode) {
        [self syncFeatures];
    }
}

-(void) loadAppDataFailHandlerWithErrorCode:(NSInteger)code andMessage:(NSString*)message {
    _isLoading = NO;
    _connected = NO;
    if ([saltrRequestDelegate respondsToSelector:@selector(didFailGettingAppDataRequest:)]) {
        SLTError* error = [[SLTError alloc] initWithCode:code andMessage:message];
        [saltrRequestDelegate didFailGettingAppDataRequest:error];
    }
}

-(void) syncFeatures {
    NSString* urlVars = [NSString stringWithFormat:@"?command=%@&instanceKey=%@", COMMAND_SAVE_OR_UPDATE_FEATURE, _instanceKey];
    
    if (appVersion) {
        urlVars = [urlVars stringByAppendingFormat:@"&appVersion=%@", appVersion];
    }
    NSMutableArray* featureList = [NSMutableArray new];
    for (NSString* key in [_features allKeys]) {
        SLTFeature* feature = [_features objectForKey:key];
        if (feature.defaultProperties) {
            
            NSError* error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:feature.defaultProperties
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (!error) {
                NSString *jsonFeatureProperties = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSDictionary* featureJSON = @{ @"token" : feature.token, @"value" : jsonFeatureProperties};
                [featureList addObject:featureJSON];
            }
        }
    }
    if ([featureList count]) {
        NSError* error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:featureList
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (!error) {
            NSString *jsonArguments = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            urlVars = [urlVars stringByAppendingFormat:@"&data=%@", jsonArguments];
        }
        SLTResourceURLTicket* ticket = [[SLTResourceURLTicket alloc] initWithURL:SALTR_URL andVariables:urlVars];
        void (^syncSuccessCallback)(SLTResource*) = ^(SLTResource *resource) {
        };
        void (^syncFailCallback)(SLTResource *) = ^(SLTResource *resource) {
        };
        SLTResource* resource = [[SLTResource alloc] initWithId:@"saveOrUpdateFeature" andTicket:ticket successHandler:syncSuccessCallback errorHandler:syncFailCallback progressHandler:nil];
        [resource load];
    }
}

-(void)loadLevelContentDataFromSaltr:(SLTLevelPack *)levelPackData
                     levelData:(SLTLevel *)levelData forceNoCache:(BOOL)forceNoCache {
    
    NSInteger timeInterval = [NSDate timeIntervalSinceReferenceDate] * 1000;
    NSString* url = [levelData.contentDataUrl stringByAppendingFormat:@"?_time_=%d", timeInterval];
    NSString* dataUrl = forceNoCache ? url : levelData.contentDataUrl;
    SLTResourceURLTicket* ticket = [[SLTResourceURLTicket alloc] initWithURL:dataUrl andVariables:nil];
    
    void (^loadSuccessCallback)(SLTResource *) = ^(SLTResource * resource) {
        NSDictionary* contentData = resource.jsonData;
        if (contentData) {
            [self cacheLevelContentData:levelPackData andLevel:levelData andContentData:contentData];
        } else {
            contentData = [self loadLevelContentDataFromInternalStorage:levelPackData andLevel:levelData];
        }
        
        if (contentData) {
            [self contentDataLoadSuccessCallback:levelData data:contentData];
        } else {
            [self contentDataLoadFailedCallback];
        }
        [resource dispose];

    };
    void (^loadFailedCallback)(SLTResource *) = ^(SLTResource * resource) {
        NSDictionary* contentData = [self loadLevelContentDataFromInternalStorage:levelPackData andLevel:levelData];
        [self contentDataLoadSuccessCallback:levelData data:contentData];
        [resource dispose];

    };
    SLTResource* resource = [[SLTResource alloc] initWithId:@"saltr" andTicket:ticket successHandler:loadSuccessCallback errorHandler:loadFailedCallback progressHandler:nil];
    [resource load];
}

-(NSDictionary *) loadLevelContentDataFromCache:(SLTLevelPack *)levelPack andLevel:(SLTLevel *)level
              {
    NSString* url = LEVEL_CONTENT_DATA_URL_CACHE_TEMPLATE(levelPack.index, level.index);
    return [SLTRepository objectFromCache:url];
}

-(void) contentDataLoadSuccessCallback:(SLTLevel *)levelData data:(id)data {
    [levelData updateContent:data];
    if ([saltrRequestDelegate respondsToSelector:@selector(didFinishGettingLevelDataBodyWithLevelPackRequest)]) {
        [saltrRequestDelegate didFinishGettingLevelDataBodyWithLevelPackRequest];
    }
}

-(void)contentDataLoadFailedCallback {
    if ([saltrRequestDelegate respondsToSelector:@selector(didFailGettingLevelDataBodyWithLevelPackRequest)]) {
        [saltrRequestDelegate didFailGettingLevelDataBodyWithLevelPackRequest];
    }
}

-(NSString *) cachedLevelVersion:(SLTLevelPack *)levelPack andLevel:(SLTLevel *)level {
    NSString* cachedFileName = LEVEL_CONTENT_DATA_URL_CACHE_TEMPLATE(levelPack.index, level.index);
    return [SLTRepository objectVersion:cachedFileName];

}

-(void) cacheLevelContentData:(SLTLevelPack *)levelPack andLevel:(SLTLevel *)level andContentData:(NSDictionary *)contentData {
    NSString* cachedFileName = LEVEL_CONTENT_DATA_URL_CACHE_TEMPLATE(levelPack.index, level.index);
    [SLTRepository cacheObject:cachedFileName version:level.version object:contentData];
}

-(NSDictionary *)loadLevelContentDataFromInternalStorage:(SLTLevelPack *)levelPack
                                                andLevel:(SLTLevel *)level {
    NSDictionary* contentData = [self loadLevelContentDataFromCache:levelPack andLevel:level];
    if (!contentData) {
        contentData = [self loadLevelContentDataFromPackage:levelPack andLevel:level];
    }
    return contentData;
}

/// @todo it would be nice to make this function public to handle case when user just wants to import level packs and levels from package
-(NSDictionary *)loadLevelContentDataFromPackage:(SLTLevelPack *)levelPack andLevel:(SLTLevel *)level {
    NSString* url = LEVEL_CONTENT_DATA_URL_PACKAGE_TEMPLATE(levelPack.index, level.index);
    return [SLTRepository objectFromApplication:url];
}

@end
