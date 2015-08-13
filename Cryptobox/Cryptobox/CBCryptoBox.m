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


NSURL *__nullable CBCreateTemporaryDirectoryAndReturnURL()
{
    NSError *error = nil;
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        return nil;
    }
    
    return directoryURL;
}

const NSUInteger CBMaxPreKeyID = 0xFFFE;



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
    NSParameterAssert(sessionId);
    
    @synchronized(self) {
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

- (BOOL)deleteSessionWithId:(NSString *)sessionId error:(NSError *__nullable * __nullable)error
{
    NSParameterAssert(sessionId);
    @synchronized(self) {
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        CBSession *session = [self.sessions objectForKey:sessionId];
        if (session) {
            [session close];
            [self.sessions removeObjectForKey:sessionId];
        }
        CBoxResult result = cbox_session_delete(_boxBacking, [sessionId UTF8String]);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorAndValueIfNotSuccess(result, error, NO);
        
        return YES;
    }
}

- (nullable NSData *)localFingerprint:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        CBoxVecRef vector = NULL;
        cbox_fingerprint_local(_boxBacking, &vector);
        CBPreKey *preKey = [[CBPreKey alloc] initWithCBoxVecRef:vector];
        return [preKey content];
    }
}

- (nullable CBPreKey *)lastPreKey:(NSError *__nullable * __nullable)error
{
    @synchronized(self) {
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        CBPreKey *preKey = [CBPreKey preKeyWithId:CBOX_LAST_PREKEY_ID boxRef:_boxBacking error:error];
        
        return preKey;
    }
}

- (nullable NSArray *)generatePreKeys:(NSRange)range error:(NSError *__nullable * __nullable)error
{
    if (range.location > CBMaxPreKeyID) {
        if (error != NULL) {
            *error = [NSError cb_errorWithErrorCode:CBErrorCodeIllegalArgument description:[NSString stringWithFormat:@"location must be >= 0 and <= %lu", (unsigned long)CBMaxPreKeyID]];
            return nil;
        }
    }
    if (range.length < 1 || range.length > CBMaxPreKeyID) {
        if (error != NULL) {
            *error = [NSError cb_errorWithErrorCode:CBErrorCodeIllegalArgument description:[NSString stringWithFormat:@"length must be >= 1 and <=  %lu", (unsigned long)CBMaxPreKeyID]];
            return nil;
        }
    }
    @synchronized(self) {
        CBReturnWithErrorAndValueIfClosed([self isClosed], error, nil);
        
        NSMutableArray *newKeys = [NSMutableArray arrayWithCapacity:range.length];
        for (NSUInteger i = 0; i < range.length; ++i) {
            uint16_t newId = (range.location + i) % 0xFFFF;
            
            CBPreKey *preKey = [CBPreKey preKeyWithId:newId boxRef:_boxBacking error:error];
            if (*error != NULL || preKey == nil) {
                return nil;
            }
            [newKeys addObject:preKey];
        }
        
        return newKeys;
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
        BOOL success = YES;
        if (! [self closeAllSessions:error]) {
            success = NO;
        }
        [self closeInternally];
        
        return success;
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