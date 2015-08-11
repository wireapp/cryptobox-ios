//
//  CBMacros.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 11.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "NSError+Cryptobox.h"



#define CBReturnWithErrorValueAndActionIfClosed(closed, error, action) \
    do { \
        if (closed) { \
            if (error != NULL) { \
                *error = [NSError cb_errorWithErrorCode:CBErrorCodeIllegalState]; \
            } \
            action; \
        } \
    } while (0)

#define CBReturnWithErrorAndValueIfClosed(closed, error, value) \
    CBReturnWithErrorValueAndActionIfClosed(closed, error, return (value))

#define CBReturnWithErrorAndValueIfNotSuccess(result, error, value) \
    do { \
        if (result != CBOX_SUCCESS) { \
            CBErrorWithCBoxResult(result, error); \
            return (value); \
        } \
    } while (0);

#define CBErrorWithCBoxResult(result, error) \
    do { \
        if (error != NULL) { \
            *error = [NSError cb_errorWithErrorCode:CBErrorCodeFromCBoxResult(result)]; \
        } \
    } while (0)

#define CBAssertResultIsSuccess(result) \
    do { \
        NSAssert(result == CBOX_SUCCESS, @""); \
    } while (0);

