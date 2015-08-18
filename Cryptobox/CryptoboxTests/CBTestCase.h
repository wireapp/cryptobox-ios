// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <XCTest/XCTest.h>

#import "CBCryptoBox.h"
@class CBPreKey;



@interface CBTestCase : XCTestCase

- (CBCryptoBox *)createBoxAndCheckAsserts;

- (NSArray *)generatePreKeysAndCheckAssertsWithRange:(NSRange)range box:(CBCryptoBox *)box;

- (CBPreKey *)generatePreKeyAndCheckAssertsWithLocation:(NSUInteger)location box:(CBCryptoBox *)box;


@end
