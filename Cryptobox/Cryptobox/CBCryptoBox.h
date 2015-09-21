// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>

@class CBSession;
@class CBPreKey;
@class CBSessionMessage;



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
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (nullable CBSession *)sessionWithId:(nonnull NSString *)sessionId fromPreKey:(nonnull CBPreKey *)preKey error:(NSError *__nullable * __nullable)error;

/// Initialise a @c CBSession using a received encrypted message.
/// This is the entry point for the recipient of an encrypted message.
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (nullable CBSessionMessage *)sessionMessageWithId:(nonnull NSString *)sessionId fromMessage:(nonnull NSData *)message error:(NSError *__nullable * __nullable)error;

/// Get an existing session by @c sessionId
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (nullable CBSession *)sessionById:(nonnull NSString *)sessionId error:(NSError *__nullable * __nullable)error;

/// Deletes an existing session. If the session is currently loaded, it is automatically closed before being deleted.
///
/// Note: After a session has been deleted, further messages from the peer can no longer be decrypted. Furthermore, initialising a new session with the peer from a new prekey and sending messages will result in the peer not being able to decrypt these messages until the old session is deleted by the peer as well.
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (BOOL)deleteSessionWithId:(nonnull NSString *)sessionId error:(NSError *__nullable * __nullable)error;

/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (nullable NSData *)localFingerprint:(NSError *__nullable * __nullable)error;

/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (nullable CBPreKey *)lastPreKey:(NSError *__nullable * __nullable)error;

/// NSRange.location = start
/// NSRange.length = number
/// @throws NSInvalidArgumentException
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (nullable NSArray *)generatePreKeys:(NSRange)range error:(NSError *__nullable * __nullable)error;

- (void)closeSession:(nonnull CBSession *)session;

/// Close all open sessions
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (void)closeAllSessions;

/// Close the CryptoBox
/// Note: After a box has been closed, any operations other than @c close are considered programmer error and result in @c CBCodeIllegalStateException
/// @throws CBCodeIllegalStateException in case @c CBCryptoBox is closed already
- (void)close;

- (BOOL)isClosed;

@end
