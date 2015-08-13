//
//  CBPreKey.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBPreKey.h"

#import "NSError+Cryptobox.h"
#import "CBMacros.h"
#import "CBVector.h"



@interface CBPreKey ()

@property (nonatomic) CBVector *vector;

@end

@implementation CBPreKey

- (instancetype)initWithVector:(CBVector *)vector
{
    self = [super init];
    if (self) {
        self.vector = vector;
    }
    return self;
}

- (NSData * __nullable)content
{
    return self.vector.data;
}

@end



@implementation CBPreKey (Internal)

+ (nullable instancetype)preKeyWithId:(uint16_t)identifier boxRef:(nonnull CBoxRef)boxRef error:(NSError *__nullable * __nullable)error
{
    NSParameterAssert(boxRef);
    
    if (! boxRef) {
        if (error != NULL) {
            *error = [NSError cb_errorWithErrorCode:CBErrorCodeIllegalArgument description:@"boxRef is not set"];
        }
        return nil;
    }
    
    CBoxVecRef vectorBacking = NULL;
    CBoxResult result = cbox_new_prekey(boxRef, identifier, &vectorBacking);
    CBAssertResultIsSuccess(result);
    CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
    CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:vectorBacking];
    return [[CBPreKey alloc] initWithVector:vector];
}

@end
