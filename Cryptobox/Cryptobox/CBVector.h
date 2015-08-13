//
//  CBVector.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 13.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBTypes.h"



/// Wrapps CBoxVec
@interface CBVector : NSObject

@property (nonatomic, readonly, nullable) NSData *data;

@end



@interface CBVector (Internal)

- (nonnull instancetype)initWithCBoxVecRef:(nonnull CBoxVecRef)vector;
+ (nonnull instancetype)vectorWithCBoxVecRef:(nonnull CBoxVecRef)vector;

- (nonnull uint8_t *)dataArray;

- (uint32_t)length;

@end
