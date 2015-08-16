//
//  CBBasicCryptoTest.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CBTestCase.h"

#import "Cryptobox.h"


@interface CBBasicCryptoTest : CBTestCase

@property (nonatomic) CBCryptoBox *aliceBox;
@property (nonatomic) CBCryptoBox *bobBox;

@end

@implementation CBBasicCryptoTest

- (void)setUp
{
    [super setUp];
    
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatBasicTestCanRun
{
    [self createBoxes];
    
    CBPreKey *bobPreKey = [self generateSinglePreKeyAndCheckAsserts:self.bobBox];
    
    
    NSError *error = nil;
    CBSession *aliceSession = [self.aliceBox sessionWithId:@"alice" fromPreKey:bobPreKey error:&error];
    XCTAssertNil(error, @"Error is not nil");
    XCTAssertNotNil(aliceSession, @"Session creation from prekey failed");
    
    [aliceSession save:&error];
    XCTAssertNil(error, @"Error is not nil");
    
    // Encrypt a message from bob
    NSData *plainData = [@"Hello Bob!" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [aliceSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipherData);
    XCTAssertNotEqual(plainData, cipherData);
    
    
    
    
    //
    return;
    CBSession *bobSession = nil;
    CBSessionMessage *sessionMessage = [self.bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(sessionMessage);
    XCTAssertNotNil(sessionMessage.session);
    XCTAssertNotNil(sessionMessage.message);
    
    bobSession = sessionMessage.session;

    [bobSession save:&error];
    XCTAssertNil(error);
}

- (CBPreKey *)generateSinglePreKeyAndCheckAsserts:(CBCryptoBox *)box
{
    NSError *error = nil;
    CBPreKey *preKey = nil;
    NSArray *keys = [self.bobBox generatePreKeys:(NSRange){1, 1} error:&error];
    XCTAssertNotNil(keys, @"Failed to generate keys");
    XCTAssert(keys.count == 1, @"Wrong amount of keys generated");
    preKey = keys[0];
    XCTAssertNotNil(preKey, @"");
    
    return preKey;
}

- (void)createBoxes
{
    self.aliceBox = [self createBoxAndCheckAsserts];
    self.bobBox = [self createBoxAndCheckAsserts];
}

@end
