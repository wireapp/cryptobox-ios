//
//  CBTestCase.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CBCryptoBox.h"
@class CBPreKey;



@interface CBTestCase : XCTestCase

- (CBCryptoBox *)createBoxAndCheckAsserts;

- (NSArray *)generatePreKeysAndCheckAssertsWithRange:(NSRange)range box:(CBCryptoBox *)box;

- (CBPreKey *)generatePreKeyAndCheckAssertsWithLocation:(NSUInteger)location box:(CBCryptoBox *)box;


@end
