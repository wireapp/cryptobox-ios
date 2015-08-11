//
//  CBBox.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBCryptoBox.h"

#import "CBSession.h"
#import "CBPreKey.h"
#import "NSError+Cryptobox.h"
#import "cbox.h"
#import "CBMacros.h"
#import "CBSessionMessage.h"



@interface CBCryptoBox () {
    CBoxRef _boxBacking;
}

/// All the existing sessions
@property (nonatomic, strong) NSMutableDictionary *sessions;

@end

@implementation CBCryptoBox

+ (nullable instancetype)cryptoBoxWithPathURL:(nonnull NSURL *)directory error:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        NSParameterAssert(directory);
        
        CBoxRef cbox = NULL;
        CBoxResult result = cbox_file_open([directory.path UTF8String], &cbox);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
        CBCryptoBox *cryptoBox = [[CBCryptoBox alloc] initWithCBoxRef:cbox];
        
        return cryptoBox;
    }
}

- (void)dealloc
{
    if (_boxBacking != NULL) {
        [self closeInternally];
    }
}

- (nullable CBSession *)sessionWithId:(nonnull NSString *)sessionId preKey:(nonnull CBPreKey *)preKey error:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        NSParameterAssert(sessionId);
        NSParameterAssert(preKey);
        
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        CBSession *session = [self.sessions objectForKey:sessionId];
        if (session) {
            return session;
        }
        CBoxResult result;
        CBoxSessionRef sessionBacking = NULL;
        result = cbox_session_init_from_prekey(_boxBacking, [sessionId UTF8String], preKey.data, preKey.length, &sessionBacking);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
        session = [[CBSession alloc] initWithCBoxSessionRef:sessionBacking];
        [self.sessions setObject:session forKey:sessionId];
        
        return session;
    }
}

- (nullable CBSessionMessage *)sessionMessageWithId:(nonnull NSString *)sessionId message:(nonnull NSData *)message error:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        NSParameterAssert(sessionId);
        NSParameterAssert(message);
        
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        
        CBSession *session = [self.sessions objectForKey:sessionId];
        if (session) {
            NSData *plain = [session decrypt:message error:error];
            if (error) {
                return nil;
            }
            return [[CBSessionMessage alloc] initWithSession:session message:plain];
        } else {
            CBoxSessionRef sessionBacking = NULL;
            CBoxVecRef plain = NULL;
            const uint8_t *bytes = (const uint8_t*)message.bytes;
            CBoxResult result = cbox_session_init_from_message(_boxBacking, [sessionId UTF8String], bytes, sizeof(bytes), &sessionBacking, &plain);
            CBAssertResultIsSuccess(result);
            CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
            
            // Fetch the plain data
            CBPreKey *preKey = [[CBPreKey alloc] initWithCBoxVecRef:plain];
            // TODO: Unsure about this
            if (! preKey.content) {
                if (error != NULL) {
                    *error = [NSError cb_errorWithErrorCode:CBErrorCodeDecodeError];
                }
                return nil;
            }
            
            // Create the new session
            CBSession *session = [[CBSession alloc] initWithCBoxSessionRef:sessionBacking];
            [self.sessions setObject:session forKey:sessionId];
            
            return [[CBSessionMessage alloc] initWithSession:session message:preKey.content];
        }
    }
}

- (nullable CBSession *)sessionById:(nonnull NSString *)sessionId error:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        NSParameterAssert(sessionId);
        
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        CBSession *session = [self.sessions objectForKey:sessionId];
        if (! session) {
            CBoxSessionRef sessionBacking = NULL;
            CBoxResult result = cbox_session_get(_boxBacking, [sessionId UTF8String], &sessionBacking);
            CBAssertResultIsSuccess(result);
            CBReturnWithErrorAndValueIfNotSuccess(result, error, nil);
            session = [[CBSession alloc] initWithCBoxSessionRef:sessionBacking];
            [self.sessions setObject:session forKey:sessionId];
        }
        
        return session;
    }
}

- (BOOL)closeAllSessions:(NSError *__nullable * __nullable)error;
{
    @synchronized(self) {
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, NO);
        
        for (CBSession *session in self.sessions) {
            [session close];
        }
        [self.sessions removeAllObjects];
        
        return YES;
    }
}

- (BOOL)close:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        if ([self isClosed]) {
            return YES;
        }

        if (! [self closeAllSessions:error]) {
            return NO;
        }
        [self closeInternally];
        
        return YES;
    }
}

- (BOOL)isClosed
{
    @synchronized(self) {
        return (_boxBacking == NULL);
    }
}

- (void)closeInternally
{
    cbox_close(_boxBacking);
    _boxBacking = NULL;
}

@end



@implementation CBCryptoBox (Internal)

- (nonnull instancetype)initWithCBoxRef:(nonnull CBoxRef)box
{
    self = [super init];
    if (self) {
        _boxBacking = box;
        self.sessions = [NSMutableDictionary new];
    }
    return self;
}

@end