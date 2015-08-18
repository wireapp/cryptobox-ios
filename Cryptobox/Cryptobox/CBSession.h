// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>

#import "CBTypes.h"



@interface CBSession : NSObject

@property (nonatomic, readonly, copy, nonnull) NSString *sessionId;

- (BOOL)save:(NSError *__nullable * __nullable)error;

/// Encrypt a byte array containing plaintext.
- (nullable NSData *)encrypt:(nonnull NSData *)plain error:(NSError *__nullable * __nullable)error;

/// Decrypt a byte array containing plaintext.
- (nullable NSData *)decrypt:(nonnull NSData *)cipher error:(NSError *__nullable * __nullable)error;

/// Get the remote fingerprint as a hex-encoded byte array
- (nullable NSData *)remoteFingerprint;

- (BOOL)isClosed;

@end

