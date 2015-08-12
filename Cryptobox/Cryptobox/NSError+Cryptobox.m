//
//  NSError+Cryptobox.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "NSError+Cryptobox.h"



NSString *const CBErrorDomain = @"CryptoboxErrorDomain";

CBErrorCode CBErrorCodeFromCBoxResult(CBoxResult result)
{
    switch (result) {
        case CBOX_STORAGE_ERROR:
            return CBErrorCodeStorageError;
            break;
            
        case CBOX_NO_SESSION:
            return CBErrorCodeNoSession;
            break;
            
        case CBOX_DECODE_ERROR:
            return CBErrorCodeDecodeError;
            break;

        case CBOX_REMOTE_IDENTITY_CHANGED:
            return CBErrorCodeRemoteIdentityChanged;
            break;

        case CBOX_INVALID_SIGNATURE:
            return CBErrorCodeInvalidSignature;
            break;

        case CBOX_INVALID_MESSAGE:
            return CBErrorCodeInvalidMessage;
            break;

        case CBOX_DUPLICATE_MESSAGE:
            return CBErrorCodeDuplicateMessage;
            break;

        case CBOX_TOO_DISTANT_FUTURE:
            return CBErrorCodeTooDistantFuture;
            break;

        case CBOX_OUTDATED_MESSAGE:
            return CBErrorCodeOutdatedMessage;
            break;

        case CBOX_UTF8_ERROR:
            return CBErrorCodeUTF8Error;
            break;

        case CBOX_NUL_ERROR:
            return CBErrorCodeNULError;
            break;

        case CBOX_ENCODE_ERROR:
            return CBErrorCodeEncodeError;
            break;
            
        case CBOX_SUCCESS:
            return CBErrorCodeUndefined;
    }
    return CBErrorCodeUndefined;
}



@implementation NSError (Cryptobox)

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code
{
    return [self cb_errorWithErrorCode:code userInfo:nil];
}

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code description:(NSString *)description
{
    if (description.length > 0) {
        return [self cb_errorWithErrorCode:code userInfo:@{NSLocalizedDescriptionKey: description}];
    } else {
        return [self cb_errorWithErrorCode:code userInfo:nil];
    }
}

+ (instancetype)cb_errorWithErrorCode:(CBErrorCode)code userInfo:(NSDictionary *)dict
{
    NSError *error = [NSError errorWithDomain:CBErrorDomain code:code userInfo:dict];
    return error;
}

@end
