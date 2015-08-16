//
//  CBTestCase.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBTestCase.h"

#import "Cryptobox.h"



@implementation CBTestCase

- (CBCryptoBox *)createBoxAndCheckAsserts
{
    NSURL *url = CBCreateTemporaryDirectoryAndReturnURL();
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:url error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(box, @"Failed to create alice box");
    
    return box;
}


- (NSArray *)generatePreKeysAndCheckAssertsWithRange:(NSRange)range box:(CBCryptoBox *)box
{
    NSError *error = nil;
    NSArray *keys = [box generatePreKeys:range error:&error];
    XCTAssertNotNil(keys);
    XCTAssertTrue(keys.count == range.length);
    return keys;
}

- (CBPreKey *)generatePreKeyAndCheckAssertsWithLocation:(NSUInteger)location box:(CBCryptoBox *)box
{
    NSArray *keys = [self generatePreKeysAndCheckAssertsWithRange:(NSRange){location, 1} box:box];
    XCTAssertTrue(keys.count == 1, @"Wrong amount of keys generated");
    CBPreKey *preKey = keys[0];
    XCTAssertNotNil(preKey);
    return preKey;
}

@end
