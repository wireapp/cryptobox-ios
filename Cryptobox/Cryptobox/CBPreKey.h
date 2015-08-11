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

@property (nonatomic) NSData *content;


@end

@interface CBPreKey (Internal)

- (instancetype)initWithCBoxVecRef:(CBoxVecRef)vec;

@end
