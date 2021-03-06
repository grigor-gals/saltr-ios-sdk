/*
 * @file
 * Saltr
 *
 * Copyright Teoken LLC. (c) 2014. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

#import "SLTResourceURLTicket.h"

@implementation SLTResourceURLTicket

@synthesize authenticate= _authenticate;
@synthesize cacheResponse=_cacheResponse;
@synthesize contentType=_contentType;
@synthesize variables=_variables;
@synthesize followRedirects=_followRedirects;
@synthesize idleTimeout=_idleTimeout;
@synthesize manageCookies=_manageCookies;
@synthesize method=_method;
@synthesize requestHeaders=_requestHeaders;
@synthesize url=_url;
@synthesize useCache=_useCache;
@synthesize userAgent=_userAgent;
@synthesize maxAttemps=_maxAttemps;
@synthesize checkPolicy=_checkPolicy;
@synthesize useSameDomain=_useSameDomain;
@synthesize dropTimeout=_dropTimeout;

-(id) initWithURL:(NSString *)urlString andVariables:(NSString *)variables {
    self = [super init];
    if (self) {
        _url = urlString;
        _variables = variables;
        _authenticate = YES;
        _cacheResponse = YES;
        _followRedirects = YES;
        _manageCookies = YES;
        _useCache = YES;
        _idleTimeout = 0;
        _method = @"GET";
        _checkPolicy = NO;
        _maxAttemps = 3;
        _useSameDomain = YES;
        _dropTimeout = 0;
        _requestHeaders = [[NSMutableDictionary alloc] init];

    }
    return self;
}

-(NSURLRequest *) urlRequest {
    NSString* jsonArguments = _url;

    if (_variables) {
        jsonArguments = [jsonArguments stringByAppendingString:_variables];
    }
    
    jsonArguments = [jsonArguments stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:jsonArguments];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:
                                     url];
    request.timeoutInterval = _idleTimeout;
    [request setHTTPShouldHandleCookies:_manageCookies];
    [request setHTTPMethod:_method];
    [request setAllHTTPHeaderFields:_requestHeaders];
    return request;
}

-(void) addHeader:(NSString *)headerName andHeaderValue:(NSString *)headerValue {
    [_requestHeaders setValue:headerValue forKey:headerName];
}

-(NSString *)headerValue:(NSString *)headerName {
    if ([[_requestHeaders allKeys] containsObject:headerName]) {
        return [_requestHeaders valueForKey:headerName];
    }
    return nil;
}

@end
