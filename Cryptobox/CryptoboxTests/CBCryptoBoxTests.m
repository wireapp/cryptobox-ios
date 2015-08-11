//
//  CBCryptoBoxTests.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 11.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "Cryptobox.h"

@interface CBCryptoBoxTests : XCTestCase

@end

@implementation CBCryptoBoxTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

static NSURL *CreateTemporaryDirectoryAndReturnURL() {
    NSError *error = nil;
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    return directoryURL;
}


- (void)testThatCryptoBoxInitWithPathWorks
{
    NSURL *directory = CreateTemporaryDirectoryAndReturnURL();
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:directory error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(box);
}

@end
