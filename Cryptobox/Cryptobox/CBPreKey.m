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



@interface CBPreKey () {
    CBoxVecRef _boxVec;
}

@property (nonatomic, readwrite) NSData *content;

@end

@implementation CBPreKey

- (void)dealloc
{
    if (_boxVec != NULL) {
        cbox_vec_free(_boxVec);
        _boxVec = NULL;
    }
}

@end



@implementation CBPreKey (Internal)

- (nonnull instancetype)initWithCBoxVecRef:(nonnull CBoxVecRef)vec
{
    self = [super init];
    if (self) {
        _boxVec = vec;
        uint32_t length = cbox_vec_len(_boxVec);
        uint8_t *data = cbox_vec_data(_boxVec);
        NSData *content = [NSData dataWithBytes:data length:length];
        self.content = content;
    }
    return self;
}

+ (nullable instancetype)preKeyWithId:(uint16_t)identifier boxRef:(nonnull CBoxRef)boxRef error:(NSError *__nullable * __nullable)error
{
    NSParameterAssert(boxRef);
    
    if (! boxRef) {
        if (error != NULL) {
            *error = [NSError cb_errorWithErrorCode:CBErrorCodeIllegalArgument description:@"boxRef is not set"];
        }
        return nil;
    }
    
    CBoxVecRef preKeyBacking = NULL;
    CBoxResult result = cbox_new_prekey(boxRef, identifier, &preKeyBacking);
    CBAssertResultIsSuccess(result);
    CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
    CBPreKey *preKey = [[CBPreKey alloc] initWithCBoxVecRef:preKeyBacking];
    return preKey;
}

- (nonnull uint8_t *)data
{
    return cbox_vec_data(_boxVec);
}

- (uint32_t)length
{
    return cbox_vec_len(_boxVec);
}

@end
