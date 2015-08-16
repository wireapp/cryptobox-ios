//
//  CBMacros.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 11.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "NSError+Cryptobox.h"



#define CBReturnWithErrorIfClosed(closed, error) \
    do { \
        if (closed) { \
            CBErrorWithCBErrorCode(CBErrorCodeIllegalState, error); \
            return; \
        } \
    } while (0)

#define CBReturnWithErrorIfNotSuccess(result, error) \
    do { \
        if (result != CBOX_SUCCESS) { \
            CBErrorWithCBoxResult(result, error); \
            return; \
        } \
    } while (0);

#define CBErrorWithCBErrorCode(code, error) \
    do { \
        if (error != NULL) { \
            *error = [NSError cb_errorWithErrorCode:code]; \
        } \
    } while (0)

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

