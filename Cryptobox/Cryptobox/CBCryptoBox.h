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
@class CBSessionMessage;



FOUNDATION_EXPORT NSURL *__nullable CBCreateTemporaryDirectoryAndReturnURL();

FOUNDATION_EXPORT const NSUInteger CBMaxPreKeyID;



@interface CBCryptoBox : NSObject

/// Opens the crypto box at the directory path
/// @param path     directory url path
+ (nullable instancetype)cryptoBoxWithPathURL:(nonnull NSURL *)directory error:(NSError *__nullable * __nullable)error;

/// Don't use! Use cryptoBoxWithPathURL:error: method instead
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Initialise a @c CBSession using the @c preKey of a peer.
/// This is the entry point for the initiator of a session, i.e. the side that wishes to send the first message.
/// @param sessionId    The ID of the new session.
/// @param prekey       The preKey of the peer.
/// @param error        Error reference
- (nullable CBSession *)sessionWithId:(nonnull NSString *)sessionId preKey:(nonnull CBPreKey *)preKey error:(NSError *__nullable * __nullable)error;

/// Initialise a @c CBSession using a received encrypted message.
/// This is the entry point for the recipient of an encrypted message.
- (nullable CBSessionMessage *)sessionMessageWithId:(nonnull NSString *)sessionId message:(nonnull NSData *)message error:(NSError *__nullable * __nullable)error;

- (nullable CBSession *)sessionById:(nonnull NSString *)sessionId error:(NSError *__nullable * __nullable)error;

- (nullable NSData *)localFingerprint:(NSError *__nullable * __nullable)error;

/// NSRange.location = start
/// NSRange.length = number
- (nullable NSArray *)generatePreKeys:(NSRange)range error:(NSError *__nullable * __nullable)error;

///
- (BOOL)closeAllSessions:(NSError *__nullable * __nullable)error;

/// Close the CryptoBox
/// Note: After a box has been closed, any operations other than @c close are considered programmer error and result in @c NSError returns on other methods
- (BOOL)close:(NSError *__nullable * __nullable)error;

- (BOOL)isClosed;

@end



@interface CBCryptoBox (Internal)

- (nonnull instancetype)initWithCBoxRef:(nonnull CBoxRef)box;

@end