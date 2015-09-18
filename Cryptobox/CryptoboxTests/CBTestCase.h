// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <XCTest/XCTest.h>

#import "CBCryptoBox.h"
@class CBPreKey;



FOUNDATION_EXPORT NSURL *__nullable CBCreateTemporaryDirectoryAndReturnURL(NSString * __nonnull name);



@interface CBTestCase : XCTestCase

- (nullable CBCryptoBox *)createBoxAndCheckAsserts:(NSString * __nonnull)userName;

- (nullable NSArray *)generatePreKeysAndCheckAssertsWithRange:(NSRange)range box:(nonnull CBCryptoBox *)box;

- (nullable CBPreKey *)generatePreKeyAndCheckAssertsWithLocation:(NSUInteger)location box:(nonnull  CBCryptoBox *)box;

@end
