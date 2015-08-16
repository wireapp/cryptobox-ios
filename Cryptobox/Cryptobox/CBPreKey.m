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
#import "CBVector+Internal.h"
#import "CBPreKey+Internal.h"



@implementation CBPreKey

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
    if (result != CBOX_SUCCESS) {
        CBErrorWithCBoxResult(result, error);
        return nil;
    }

    CBPreKey *key = [[CBPreKey alloc] initWithCBoxVecRef:vectorBacking];
    return key;
}

@end
