/*
 * @file
 * Saltr
 *
 * Copyright Teoken LLC. (c) 2014. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

#import "PSBoardAsset.h"

@implementation PSBoardAsset

@synthesize type = _type;
@synthesize keys = _keys;

- (id)initWithType:(NSString*)theType andKeys:(NSDictionary*)theKeys
{
    self = [super init];
    if (self) {
        _type = theType;
        _keys = theKeys;
    }
    return self;
}

@end
