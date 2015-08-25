// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

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
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"boxRef is not set" userInfo:nil];
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
