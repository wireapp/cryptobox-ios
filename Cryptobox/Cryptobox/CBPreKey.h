//
//  CBPreKey.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBTypes.h"



@interface CBPreKey : NSObject

@property (nonatomic, readonly, nonnull) NSData *content;

@end

@interface CBPreKey (Internal)

- (nonnull instancetype)initWithCBoxVecRef:(nonnull CBoxVecRef)vec;

- (nonnull uint8_t *)data;

- (uint32_t)length;

@end
