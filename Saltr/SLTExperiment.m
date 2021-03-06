/*
 * @file
 * Saltr
 *
 * Copyright Teoken LLC. (c) 2014. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

#import "SLTExperiment.h"

@implementation SLTExperiment

@synthesize partition = _partition;
@synthesize token  = _token;
@synthesize type = _type;
@synthesize customEvents = _customEvents;

- (id)initWithToken:(NSString*)theToken partition:(NSString*)thePartition andType:(NSString*)theType
{
    self = [super init];
    if (self) {
        _token = theToken;
        _partition = thePartition;
        _type = theType;
    }
    return self;
}

@end
