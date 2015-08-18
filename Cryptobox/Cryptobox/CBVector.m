// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import "CBVector.h"

#import "CBVector+Internal.h"
#import "cbox.h"



@interface CBVector () {
    CBoxVecRef _vectorBacking;
}

@property (nonatomic, readwrite) NSData *data;

@end

@implementation CBVector

- (void)dealloc
{
    if (_vectorBacking != NULL) {
        cbox_vec_free(_vectorBacking);
        _vectorBacking = NULL;
    }
}

@end



@implementation CBVector (Internal)

- (nonnull instancetype)initWithCBoxVecRef:(nonnull CBoxVecRef)vector
{
    self = [super init];
    if (self) {
        _vectorBacking = vector;
        uint32_t length = cbox_vec_len(vector);
        uint8_t *data = cbox_vec_data(vector);
        self.data = [NSData dataWithBytes:data length:length];
    }
    return self;
}

+ (nonnull instancetype)vectorWithCBoxVecRef:(nonnull CBoxVecRef)vector
{
    return [[self alloc] initWithCBoxVecRef:vector];
}

- (nonnull uint8_t *)dataArray
{
    return cbox_vec_data(_vectorBacking);
}

- (uint32_t)length
{
    return cbox_vec_len(_vectorBacking);
}

@end
