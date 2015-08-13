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

+ (nullable instancetype)preKeyWithId:(uint16_t)identifier boxRef:(nonnull CBoxRef)boxRef error:(NSError *__nullable * __nullable)error;

- (nonnull uint8_t *)data;

- (uint32_t)length;

@end
