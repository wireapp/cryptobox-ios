//
//  CBPreKeyRemovalTest.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CBTestCase.h"
#import "Cryptobox.h"



@interface CBPreKeyRemovalTest : CBTestCase

@end

@implementation CBPreKeyRemovalTest


- (void)testExample
{
    CBCryptoBox *aliceBox = [self createBoxAndCheckAsserts];
    CBCryptoBox *bobBox = [self createBoxAndCheckAsserts];
    
    
    CBPreKey *bobPreKey = [self generatePreKeyAndCheckAssertsWithLocation:1 box:bobBox];
    
    NSError *error = nil;
    CBSession *aliceSession = [aliceBox sessionWithId:@"alice" fromPreKey:bobPreKey error:&error];
    XCTAssertNotNil(aliceSession);
    XCTAssertNil(error);
    
    NSString *const plain = @"Hello Bob!";
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [aliceSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipher);
    
    CBSessionMessage *bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipher error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    XCTAssertNotNil(bobSessionMessage.data);
    XCTAssertNotNil(bobSessionMessage.session);
    
    CBSession *bobSession = bobSessionMessage.session;
    
    // Pretend something happened before Bob could save his session and he retries.
    // The prekey should not be removed (yet).
    [bobSession close];
    bobSessionMessage = nil;
    
    bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipher error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    XCTAssertNotNil(bobSessionMessage.data);
    XCTAssertNotNil(bobSessionMessage.session);
    
    bobSession = bobSessionMessage.session;
    [bobSession save:&error];
    XCTAssertNil(error);
    
    // Now the prekey should be gone
    [bobSession close];

    // TODO: Figure out how to handle NSAssert's and the exception handler call
//    bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipher error:&error];
//    XCTAssertNotNil(error);
//    XCTAssertTrue(error.code == CBErrorCodeInvalidMessage);
}


@end
