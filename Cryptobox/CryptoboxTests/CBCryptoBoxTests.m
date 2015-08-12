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

- (void)testThatCryptoBoxInitWithPathWorks
{
    NSURL *directory = CBCreateTemporaryDirectoryAndReturnURL()();
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:directory error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(box);
}

@end
