//
//  CBBox.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBTypes.h"
@class CBSession;
@class CBPreKey;



@interface CBCryptoBox : NSObject

/// opens the crypto box at path
+ (nullable instancetype)cryptoBoxAtPath:(nonnull NSString *)path error:(NSError *__nullable * __nullable)error;

/// Use cryptoBoxAtPath:error: method instead
- (nonnull instancetype)init NS_UNAVAILABLE;

- (nullable CBSession *)sessionWithId:(nonnull NSString *)sessionId preKey:(nonnull CBPreKey *)preKey;

// initSessionFromMessage
//- (CBSession *)initSessionWithId:(NSString *)sessionId message:(CBPreKey *)preKey;

@end



@interface CBCryptoBox (Internal)

- (nonnull instancetype)initWithCBoxRef:(nonnull CBoxRef)box;

@end