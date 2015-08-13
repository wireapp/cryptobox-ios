//
//  CBPreKey.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBTypes.h"
#import "CBVector.h"



@interface CBPreKey : CBVector

@end



@interface CBPreKey (Internal)

+ (nullable instancetype)preKeyWithId:(uint16_t)identifier boxRef:(nonnull CBoxRef)boxRef error:(NSError *__nullable * __nullable)error;

@end
