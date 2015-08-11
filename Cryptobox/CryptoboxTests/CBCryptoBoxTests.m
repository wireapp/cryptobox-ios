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
    char alice_tmp[] = "/tmp/cbox_test_aliceXXXXXX";
    char * alice_dir = mkdtemp(alice_tmp);
    assert(alice_dir != NULL);
    NSString *filePath = [NSString stringWithUTF8String:alice_dir];
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxAtPath:filePath error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(box);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
