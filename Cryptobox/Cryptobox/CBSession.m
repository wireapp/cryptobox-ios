//
//  CBSession.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBSession.h"

#import "cbox.h"
#import "CBTypes.h"
#import "CBMacros.h"
#import "CBPreKey.h"
#import "CBVector+Internal.h"
#import "CBSession+Internal.h"



@interface CBSession () {
    CBoxSessionRef _sessionBacking;
}

@property (nonatomic) dispatch_queue_t sessionQueue;

@end

@implementation CBSession

- (void)dealloc
{
    if (_sessionBacking != NULL) {
        [self closeInternally];
    }
}

- (BOOL)save:(NSError *__nullable * __nullable)error
{
    __block BOOL success = NO;
    dispatch_sync(self.sessionQueue, ^{
        CBReturnWithErrorIfClosed([self isClosedInternally], error);
        
        CBoxResult result = cbox_session_save(_sessionBacking);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorIfNotSuccess(result, error);
        
        success = YES;
    });

    return success;
}

- (void)close
{
    dispatch_sync(self.sessionQueue, ^{
        if ([self isClosedInternally]) {
            return;
        }
        [self closeInternally];
    });
}

- (BOOL)isClosed
{
    __block BOOL closed;
    dispatch_sync(self.sessionQueue, ^{
        closed = [self isClosedInternally];
    });
    return closed;
}

- (nullable NSData *)encrypt:(nonnull NSData *)plain error:(NSError *__nullable * __nullable)error
{
    __block NSData *data = nil;
    dispatch_sync(self.sessionQueue, ^{
        NSParameterAssert(plain);
        
        CBReturnWithErrorIfClosed([self isClosedInternally], error);
        
        CBoxVecRef cipher = NULL;
        const uint8_t *bytes = (const uint8_t*)plain.bytes;
        if (bytes == NULL) {
            CBErrorWithCBErrorCode(CBErrorCodeIllegalArgument, error);
            return;
        }
        
        CBoxResult result = cbox_encrypt(_sessionBacking, bytes, sizeof(bytes), &cipher);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorIfNotSuccess(result, error);

        CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:cipher];
        data = vector.data;
    });
    
    return data;
}

- (nullable NSData *)decrypt:(nonnull NSData *)cipher error:(NSError *__nullable * __nullable)error
{
    __block NSData *data = nil;
    dispatch_sync(self.sessionQueue, ^{
        NSParameterAssert(cipher);
        
        CBReturnWithErrorIfClosed([self isClosedInternally], error);
        
        const uint8_t *bytes = (const uint8_t*)cipher.bytes;
        if (bytes == NULL) {
            CBErrorWithCBErrorCode(CBErrorCodeIllegalArgument, error);
            return;
        }
        CBoxVecRef plain = NULL;
        CBoxResult result = cbox_decrypt(_sessionBacking, bytes, sizeof(bytes), &plain);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorIfNotSuccess(result, error);
        
        CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:plain];
        
        data = vector.data;

    });
    return data;
}

- (nullable NSData *)remoteFingerprint
{
    __block NSData *fingerprint = nil;
    dispatch_sync(self.sessionQueue, ^{
        if ([self isClosedInternally]) {
            return;
        }
        CBoxVecRef vectorBacking = NULL;
        cbox_fingerprint_remote(_sessionBacking, &vectorBacking);
        fingerprint = [CBVector vectorWithCBoxVecRef:vectorBacking].data;
    });
    return fingerprint;
}

#pragma mark -

- (void)closeInternally
{
    cbox_session_close(_sessionBacking);
    _sessionBacking = NULL;
}

- (BOOL)isClosedInternally
{
    return (_sessionBacking == NULL);
}

@end



@implementation CBSession (Internal)

- (nonnull instancetype)initWithCBoxSessionRef:(nonnull CBoxSessionRef)session
{
    self = [super init];
    if (self) {
        _sessionBacking = session;
        // TODO: Can we use here DISPATCH_QUEUE_CONCURRENT check
        self.sessionQueue = dispatch_queue_create("org.pkaboo.cryptobox.sessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end
