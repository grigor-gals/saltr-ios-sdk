/*
 * @file
 * Saltr
 *
 * Copyright Teoken LLC. (c) 2014. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

#import <Foundation/Foundation.h>

/**
 * The private interface of game @b SLTDevice class.
 */
@interface SLTDevice : NSObject

/// the device Id
@property (nonatomic, strong, readonly) NSString* deviceId;

/// the device type
@property (nonatomic, strong, readonly) NSString* deviceType;

/**
 * @brief Inits instance of @b SLTDevice class with given id and type
 *
 * @param theId - device id
 * @param theType - device type
 * @return - The instance of  @b SLTDevice class
 */
-(id) initWithDeviceId:(NSString*)theId andDeviceType:(NSString*)theType;

/// Returns the dictionary value of  @b SLTDevice class
-(NSDictionary *) toDictionary;

@end
