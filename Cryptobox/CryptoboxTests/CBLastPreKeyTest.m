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

@property (nonatomic) CBCryptoBox *aliceBox;
@property (nonatomic) CBCryptoBox *bobBox;

@end

@implementation CBLastPreKeyTest

- (void)setUp
{
    [super setUp];
    
    self.aliceBox = [self createBoxAndCheckAsserts];
    self.bobBox = [self createBoxAndCheckAsserts];
}

- (void)tearDown
{
    [super tearDown];
    
    self.aliceBox = nil;
    self.bobBox = nil;
}

- (void)testThatLastPrekeyTestCanRun
{
    NSError *error = nil;
    CBPreKey *bobLastPreKey = [self.bobBox lastPreKey:&error];
    XCTAssertNotNil(bobLastPreKey);
    XCTAssertNil(error);
    
    CBSession *aliceSession = [self.aliceBox sessionWithId:@"alice" fromPreKey:bobLastPreKey error:&error];
    XCTAssertNotNil(aliceSession);
    XCTAssertNil(error);
    
    NSData *plainData = [@"Hello Bob!" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [aliceSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipherData);
    
                               
    CBSession *bobSession = nil;
    CBSessionMessage *bobSessionMessage = [self.bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    XCTAssertNotNil(bobSessionMessage.session);
    XCTAssertNotNil(bobSessionMessage.message);

    
                               
}

@end
