//
//  CBLastPreKeyTest.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CBTestCase.h"
#import "Cryptobox.h"



@interface CBLastPreKeyTest : CBTestCase

@end

@implementation CBLastPreKeyTest

- (void)testThatLastPrekeyTestCanRun
{
    CBCryptoBox *aliceBox = [self createBoxAndCheckAsserts];
    CBCryptoBox *bobBox = [self createBoxAndCheckAsserts];

    NSError *error = nil;
    CBPreKey *bobLastPreKey = [bobBox lastPreKey:&error];
    XCTAssertNotNil(bobLastPreKey);
    XCTAssertNil(error);
    
    CBSession *aliceSession = [aliceBox sessionWithId:@"alice" fromPreKey:bobLastPreKey error:&error];
    XCTAssertNotNil(aliceSession);
    XCTAssertNil(error);
    
    const NSString *plain = @"Hello Bob!";
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [aliceSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipherData);
    
                               
    CBSession *bobSession = nil;
    CBSessionMessage *bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    XCTAssertNotNil(bobSessionMessage.session);
    XCTAssertNotNil(bobSessionMessage.data);

    bobSession = bobSessionMessage.session;
    NSString *decrypted = [[NSString alloc] initWithData:bobSessionMessage.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([plain isEqualToString:decrypted]);
    
    [bobSession save:&error];
    XCTAssertNil(error);
    [bobSession close];
    bobSession = nil;
    decrypted = nil;
    
    // Bob's last prekey is not removed
    bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    decrypted = [[NSString alloc] initWithData:bobSessionMessage.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([plain isEqualToString:decrypted]);
    
    NSLog(@"%s test_last_prekey finished", __PRETTY_FUNCTION__);
}

@end
