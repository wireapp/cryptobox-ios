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

/// Very simple box init test
@interface CBCryptoBoxInitTest : XCTestCase

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
