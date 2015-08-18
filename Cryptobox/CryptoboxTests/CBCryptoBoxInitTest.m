// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "Cryptobox.h"
#import "CBTestCase.h"



/// Very simple box init test
@interface CBCryptoBoxInitTest : CBTestCase

@end

@implementation CBCryptoBoxInitTest

- (void)testThatCryptoBoxInitWithPathWorks
{
    NSURL *directory = CBCreateTemporaryDirectoryAndReturnURL();
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:directory error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(box);
    
    NSData *localFingerprint = [box localFingerprint:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(localFingerprint);
}

@end
