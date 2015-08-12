//
//  CBCryptoBoxTests.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 12.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Cryptobox.h"

@interface CBCryptoBoxTests : XCTestCase

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
    NSArray *preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, CBErrorCodeIllegalArgument);
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
    preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, CBErrorCodeIllegalArgument);
}

- (void)testThatPreKeysGenerationErrorHandlingChecksLength
{
    // Invalid input, no keys to generate
    NSRange range = (NSRange){0, 0};
    NSError *error = nil;
    NSArray *preKeys = [self.box generatePreKeys:range error:&error];
    #pragma unused(preKeys)
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, CBErrorCodeIllegalArgument);
    
    // Out of max bounds
    range = (NSRange){0, CBMaxPreKeyID + 1};
    preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, CBErrorCodeIllegalArgument);
}

@end
