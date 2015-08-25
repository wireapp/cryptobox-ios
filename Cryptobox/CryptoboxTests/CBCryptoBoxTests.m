// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Cryptobox.h"
#import "CBTestCase.h"

@interface CBCryptoBoxTests : CBTestCase

@property (nonatomic) CBCryptoBox *box;

@end

@implementation CBCryptoBoxTests

- (void)setUp
{
    [super setUp];
    
    NSURL *directory = CBCreateTemporaryDirectoryAndReturnURL();
    self.box = [CBCryptoBox cryptoBoxWithPathURL:directory error:nil];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatPreKeysAreGettingGenerated
{
    NSRange range = (NSRange){0, 10};
    NSError *error = nil;
    NSArray *preKeys = [self.box generatePreKeys:range error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(preKeys);
    XCTAssertEqual(preKeys.count, range.length);
}

- (void)testThatPreKeysGenerationErrorHandlingRespectsMaxLength
{
    NSRange range = (NSRange){0, CBMaxPreKeyID + 1};
    NSError *error = nil;
    @try {
        NSArray *preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    }
    @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInvalidArgumentException);
    }
}

- (void)testThatPreKeysGenerationErrorHandlingChecksLocation
{
    // Should pass
    NSRange range = (NSRange){CBMaxPreKeyID, 1};
    NSError *error = nil;
    NSArray *preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    XCTAssertNil(error);
    XCTAssertNotNil(preKeys);
    
    // Shouldn't pass
    range = (NSRange){CBMaxPreKeyID + 1, 1};
    @try {
        preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    }
    @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInvalidArgumentException);
    }
}

- (void)testThatPreKeysGenerationErrorHandlingChecksLength
{
    // Invalid input, no keys to generate
    NSRange range = (NSRange){0, 0};
    NSError *error = nil;
    NSArray *preKeys = nil;
    @try {
        preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    }
    @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInvalidArgumentException);
    }
    
    // Out of max bounds
    range = (NSRange){0, CBMaxPreKeyID + 1};
    @try {
        preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)

    }
    @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInvalidArgumentException);
    }
}

- (void)testThatLastPreKeyReturnsPreKey
{
    NSError *error = nil;
    CBPreKey *preKey = [self.box lastPreKey:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(preKey);
}

@end
