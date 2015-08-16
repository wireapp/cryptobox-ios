//
//  CBSession.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBTypes.h"



@interface CBSession : NSObject

- (BOOL)save:(NSError *__nullable * __nullable)error;

/// Encrypt a byte array containing plaintext.
- (nullable NSData *)encrypt:(nonnull NSData *)plain error:(NSError *__nullable * __nullable)error;

/// Decrypt a byte array containing plaintext.
- (nullable NSData *)decrypt:(nonnull NSData *)cipher error:(NSError *__nullable * __nullable)error;

/// Get the remote fingerprint as a hex-encoded byte array
- (nullable NSData *)remoteFingerprint;

- (void)close;

- (BOOL)isClosed;

@end


@interface CBSession (Internal)

- (nonnull instancetype)initWithCBoxSessionRef:(nonnull CBoxSessionRef)session;

@end