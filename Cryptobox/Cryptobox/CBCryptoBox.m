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



@interface CBCryptoBox () {
    CBoxRef _boxBacking;
}

/// All the existing sessions
@property (nonatomic, strong) NSMutableDictionary *sessions;

@end

@implementation CBCryptoBox

+ (nullable instancetype)cryptoBoxAtPath:(nonnull NSString *)path error:(NSError *__nullable * __nullable)error
{
    CBCryptoBox *cryptoBox = nil;
    @synchronized(self) {
        char const *p = [path UTF8String];
        CBoxRef cbox = NULL;
        CBoxResult result = cbox_file_open(p, &cbox);
        if (result == CBOX_SUCCESS) {
            cryptoBox = [[CBCryptoBox alloc] initWithCBoxRef:cbox];
        } else {
            if (error != NULL) {
                *error = [NSError cb_errorWithErrorCode:CBErrorCodeFromCBoxResult(result)];
            }
        }
    }
    return cryptoBox;
}

- (void)dealloc
{
    if (_boxBacking != NULL) {
        cbox_close(_boxBacking);
    }
}

- (nullable CBSession *)sessionWithId:(nonnull NSString *)sessionId preKey:(nonnull CBPreKey *)preKey
{
    
    return [CBSession new];
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