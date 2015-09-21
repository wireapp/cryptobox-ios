// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import "CBCryptoBox.h"
#import "CBTypes.h"

#import "CBSession+Internal.h"
#import "CBVector+Internal.h"
#import "CBPreKey.h"
#import "NSError+Cryptobox.h"
#import "cbox.h"
#import "CBMacros.h"
#import "CBSessionMessage.h"
#import "CBPreKey+Internal.h"
#import "CBCryptoBox+Internal.h"



static dispatch_queue_t CBOpeningQueue(void)
{
    static dispatch_queue_t openingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        openingQueue = dispatch_queue_create("org.pkaboo.cryptobox.cryptoBoxOpeningQueue", 0);
    });
    return openingQueue;
}



const NSUInteger CBMaxPreKeyID = 0xFFFE;



@interface CBCryptoBox () {
    CBoxRef _boxBacking;
}

@property (nonatomic) dispatch_queue_t cryptoBoxQueue;

/// All the existing sessions
@property (nonatomic) NSMutableDictionary *sessions;

@end

@implementation CBCryptoBox

+ (nullable instancetype)cryptoBoxWithPathURL:(nonnull NSURL *)directory error:(NSError *__nullable * __nullable)error
{
    __block CBCryptoBox *cryptoBox = nil;
    dispatch_sync(CBOpeningQueue(), ^{
        NSParameterAssert(directory);
        
        CBoxRef cbox = NULL;
        CBoxResult result = cbox_file_open([directory.path UTF8String], &cbox);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorIfNotSuccess(result, error);
        
        cryptoBox = [[CBCryptoBox alloc] initWithCBoxRef:cbox];
    });
    return cryptoBox;
}

- (void)dealloc
{
    if (! [self isClosedInternally]) {
        [self closeInternally];
    }
}

- (nullable CBSession *)sessionWithId:(nonnull NSString *)sessionId fromPreKey:(nonnull CBPreKey *)preKey error:(NSError *__nullable * __nullable)error
{
    __block CBSession *session = nil;
    
    dispatch_sync(self.cryptoBoxQueue, ^{
        NSParameterAssert(sessionId);
        NSParameterAssert(preKey);
        
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        session = [self.sessions objectForKey:sessionId];
        if (session) {
            return;
        }
        
        CBoxResult result;
        CBoxSessionRef sessionBacking = NULL;
        result = cbox_session_init_from_prekey(self->_boxBacking, [sessionId UTF8String], preKey.dataArray, preKey.length, &sessionBacking);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorIfNotSuccess(result, error);
        
        session = [[CBSession alloc] initWithCBoxSessionRef:sessionBacking sessionId:sessionId];
        [self.sessions setObject:session forKey:sessionId];
    });
    
    return session;
}

- (nullable CBSessionMessage *)sessionMessageWithId:(nonnull NSString *)sessionId fromMessage:(nonnull NSData *)message error:(NSError *__nullable * __nullable)error
{
    __block CBSessionMessage *sessionMessage = nil;
    dispatch_sync(self.cryptoBoxQueue, ^{
        NSParameterAssert(sessionId);
        NSParameterAssert(message);
        
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);

        CBSession *session = [self.sessions objectForKey:sessionId];
        NSAssert(! [session isClosed], @"Session is closed");
        if (session) {
            NSData *plain = [session decrypt:message error:error];
            if (! plain) {
                return;
            }
            sessionMessage = [[CBSessionMessage alloc] initWithSession:session data:plain];
        } else {
            CBoxSessionRef sessionBacking = NULL;
            CBoxVecRef plain = NULL;
            const uint8_t *bytes = (const uint8_t*)message.bytes;
            CBoxResult result = cbox_session_init_from_message(self->_boxBacking, [sessionId UTF8String], bytes, (uint32_t)message.length, &sessionBacking, &plain);
            CBAssertResultIsSuccess(result);

            CBReturnWithErrorIfNotSuccess(result, error);

            // Fetch the plain data
            CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:plain];
            // TODO: Unsure about this
            if (! vector.data) {
                if (error != NULL) {
                    *error = [NSError cb_errorWithErrorCode:CBErrorCodeDecodeError];
                }
                return;
            }
            
            // Create the new session
            session = [[CBSession alloc] initWithCBoxSessionRef:sessionBacking sessionId:sessionId];
            [self.sessions setObject:session forKey:sessionId];
            
            sessionMessage = [[CBSessionMessage alloc] initWithSession:session data:vector.data];
        }
    });
    
    return sessionMessage;
}

- (nullable CBSession *)sessionById:(nonnull NSString *)sessionId error:(NSError *__nullable * __nullable)error
{
    __block CBSession *session = nil;
    dispatch_sync(self.cryptoBoxQueue, ^{
        NSParameterAssert(sessionId);
        
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        session = [self.sessions objectForKey:sessionId];
        NSAssert(! [session isClosed], @"Session is closed");
        if (! session) {
            CBoxSessionRef sessionBacking = NULL;
            CBoxResult result = cbox_session_get(self->_boxBacking, [sessionId UTF8String], &sessionBacking);
            CBAssertResultIsSuccess(result);
            CBReturnWithErrorIfNotSuccess(result, error);
            
            session = [[CBSession alloc] initWithCBoxSessionRef:sessionBacking sessionId:sessionId];
            [self.sessions setObject:session forKey:sessionId];
        }
    });
    
    return session;
}

- (BOOL)deleteSessionWithId:(NSString *)sessionId error:(NSError *__nullable * __nullable)error
{
    __block BOOL success = NO;
    dispatch_sync(self.cryptoBoxQueue, ^{
        NSParameterAssert(sessionId);
        
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        CBSession *session = [self.sessions objectForKey:sessionId];
        if (session) {
            [session close];
            [self.sessions removeObjectForKey:sessionId];
        }
        
        CBoxResult result = cbox_session_delete(self->_boxBacking, [sessionId UTF8String]);
        CBAssertResultIsSuccess(result);
        CBReturnWithErrorIfNotSuccess(result, error);
        
        success = YES;
    });
    
    return success;
}

- (nullable NSData *)localFingerprint:(NSError *__nullable * __nullable __unused)error
{
    __block NSData *data = nil;
    dispatch_sync(self.cryptoBoxQueue, ^{
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        CBoxVecRef vectorBacking = NULL;
        cbox_fingerprint_local(self->_boxBacking, &vectorBacking);
        CBVector *vector = [[CBVector alloc] initWithCBoxVecRef:vectorBacking];
        data = vector.data;
    });
    
    return data;
}

- (nullable CBPreKey *)lastPreKey:(NSError *__nullable * __nullable)error
{
    __block CBPreKey *key = nil;
    dispatch_sync(self.cryptoBoxQueue, ^{
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        key = [CBPreKey preKeyWithId:CBOX_LAST_PREKEY_ID boxRef:self->_boxBacking error:error];
    });
    
    return key;
}

- (nullable NSArray *)generatePreKeys:(NSRange)range error:(NSError *__nullable * __nullable)error
{
    if (range.location > CBMaxPreKeyID) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"location must be >= 0 and <= %lu", (unsigned long)CBMaxPreKeyID] userInfo:nil];
    }
    if (range.length < 1 || range.length > CBMaxPreKeyID) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"length must be >= 1 and <=  %lu", (unsigned long)CBMaxPreKeyID] userInfo:nil];
    }
    
    __block NSArray *keys = nil;
    dispatch_sync(self.cryptoBoxQueue, ^{
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        NSMutableArray *newKeys = [NSMutableArray arrayWithCapacity:range.length];
        for (NSUInteger i = 0; i < range.length; ++i) {
            uint16_t newId = (range.location + i) % 0xFFFF;
            
            CBPreKey *preKey = [CBPreKey preKeyWithId:newId boxRef:self->_boxBacking error:error];
            if (*error != NULL || preKey == nil) {
                return;
            }
            [newKeys addObject:preKey];
        }
        
        keys = [NSArray arrayWithArray:newKeys];
    });
    
    return keys;
}

- (void)closeSession:(nonnull CBSession *)session
{
    dispatch_sync(self.cryptoBoxQueue, ^{
        if ([self isClosedInternally]) {
            return;
        }
        [self.sessions removeObjectForKey:session.sessionId];
        [session close];
    });
}

- (void)closeAllSessions
{
    dispatch_sync(self.cryptoBoxQueue, ^{
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        [self closeAllSessionsInternally];
    });
}


- (void)close
{
    dispatch_sync(self.cryptoBoxQueue, ^{
        CBThrowIllegalStageExceptionIfClosed([self isClosedInternally]);
        
        [self closeAllSessionsInternally];
        [self closeInternally];
    });
}

- (BOOL)isClosed
{
    __block BOOL closed = NO;
    dispatch_sync(self.cryptoBoxQueue, ^{
        closed = [self isClosedInternally];
    });
    return closed;
}

#pragma mark - Internal, not dispatch_sync protected methods

- (BOOL)isClosedInternally
{
    return (_boxBacking == NULL);
}

- (void)closeInternally
{
    cbox_close(_boxBacking);
    _boxBacking = NULL;
}

- (void)closeAllSessionsInternally
{
    if ([self isClosedInternally]) {
        return;
    }
    for (CBSession *session in self.sessions) {
        [session close];
    }
    [self.sessions removeAllObjects];
}

@end



@implementation CBCryptoBox (Internal)

- (nonnull instancetype)initWithCBoxRef:(nonnull CBoxRef)box
{
    self = [super init];
    if (self) {
        _boxBacking = box;
        
        self.sessions = [NSMutableDictionary new];
        // TODO: Can we use here DISPATCH_QUEUE_CONCURRENT check
        self.cryptoBoxQueue = dispatch_queue_create("org.pkaboo.cryptobox.cryptoBoxQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end
