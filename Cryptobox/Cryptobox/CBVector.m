//
//  CBVector.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 13.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

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
