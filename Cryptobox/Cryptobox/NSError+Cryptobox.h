// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>

#import "cbox.h"



typedef NS_ENUM(NSInteger, CBErrorCode) {
    CBErrorCodeUndefined,
    CBErrorCodeStorageError,
    CBErrorCodeNoSession,
    CBErrorCodeDecodeError,
    CBErrorCodeRemoteIdentityChanged,
    CBErrorCodeInvalidSignature,
    CBErrorCodeInvalidMessage,
    CBErrorCodeDuplicateMessage,
    CBErrorCodeTooDistantFuture,
    CBErrorCodeOutdatedMessage,
    CBErrorCodeUTF8Error,
    CBErrorCodeNULError,
    CBErrorCodeEncodeError,
};

FOUNDATION_EXPORT NSString *const CBErrorDomain;
FOUNDATION_EXPORT CBErrorCode CBErrorCodeFromCBoxResult(CBoxResult result);
FOUNDATION_EXPORT NSString *const CBCodeIllegalStateException;



@interface NSError (Cryptobox)

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code;

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code description:(NSString *)description;

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code userInfo:(NSDictionary *)dict;

@end
