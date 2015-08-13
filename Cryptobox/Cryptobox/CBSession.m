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
#import "CBVector.h"



@interface CBSession () {
    CBoxSessionRef _sessionBacking;
}

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
    @synchronized(self) {
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, NO);
        CBoxResult result = cbox_session_save(_sessionBacking);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorAndValueIfNotSuccess(result, error, NO);
        return YES;
    }
}

- (void)close
{
    @synchronized(self) {
        if ([self isClosed]) {
            return;
        }
        [self closeInternally];
    }
}

- (BOOL)isClosed
{
    @synchronized(self) {
        return (_sessionBacking == NULL);
    }
}

- (nullable NSData *)encrypt:(nonnull NSData *)plain error:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        NSParameterAssert(plain);
        
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        
        CBoxVecRef cipher = NULL;
        const uint8_t *bytes = (const uint8_t*)plain.bytes;
        if (bytes == NULL) {
            return nil;
        }
        CBoxResult result = cbox_encrypt(_sessionBacking, bytes, sizeof(bytes), &cipher);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
        CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:cipher];
        return vector.data;
    }
}

- (nullable NSData *)decrypt:(nonnull NSData *)cipher error:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        NSParameterAssert(cipher);
        
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        const uint8_t *bytes = (const uint8_t*)cipher.bytes;
        if (bytes == NULL) {
            return nil;
        }
        CBoxVecRef plain = NULL;
        CBoxResult result = cbox_decrypt(_sessionBacking, bytes, sizeof(bytes), &plain);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
        CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:plain];
        
        return vector.data;
    }
}

- (nullable NSData *)remoteFingerprint
{
    @synchronized(self) {
        if ([self isClosed]) {
            return nil;
        }
        CBoxVecRef vectorBacking = NULL;
        cbox_fingerprint_remote(_sessionBacking, &vectorBacking);
        return [CBVector vectorWithCBoxVecRef:vectorBacking].data;
    }
}

#pragma mark -

- (void)closeInternally
{
    cbox_session_close(_sessionBacking);
    _sessionBacking = NULL;
}

@end



@implementation CBSession (Internal)

- (nonnull instancetype)initWithCBoxSessionRef:(nonnull CBoxSessionRef)session
{
    self = [super init];
    if (self) {
        _sessionBacking = session;
    }
    return self;
}

@end
