//
//  NSError+Cryptobox.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

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
    CBErrorCodeEncodeError
};

FOUNDATION_EXPORT NSString *const CBErrorDomain;
FOUNDATION_EXPORT CBErrorCode CBErrorCodeFromCBoxResult(CBoxResult result);



@interface NSError (Cryptobox)

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code;

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code userInfo:(NSDictionary *)dict;

@end
