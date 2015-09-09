// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CBTestCase.h"

@import Cryptobox;


@interface CBBasicCryptoTest : CBTestCase

@property (nonatomic) CBCryptoBox *aliceBox;
@property (nonatomic) CBCryptoBox *bobBox;

@end

@implementation CBBasicCryptoTest

- (void)testThatBasicTestCanRun
{
    self.aliceBox = [self createBoxAndCheckAsserts];
    self.bobBox = [self createBoxAndCheckAsserts];
    
    CBPreKey *bobPreKey = [self generatePreKeyAndCheckAssertsWithLocation:1 box:self.bobBox];
    
    NSError *error = nil;
    CBSession *aliceSession = [self.aliceBox sessionWithId:@"alice" fromPreKey:bobPreKey error:&error];
    XCTAssertNil(error, @"Error is not nil");
    XCTAssertNotNil(aliceSession, @"Session creation from prekey failed");
    
    [aliceSession save:&error];
    XCTAssertNil(error, @"Error is not nil");
    
    // Encrypt a message from bob
    NSString *const plain = @"Hello Bob!";
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [aliceSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipherData);
    XCTAssertNotEqual(plainData, cipherData);
    
    CBSession *bobSession = nil;
    CBSessionMessage *bobSessionMessage = [self.bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    XCTAssertNotNil(bobSessionMessage.session);
    XCTAssertNotNil(bobSessionMessage.data);
    
    bobSession = bobSessionMessage.session;

    [bobSession save:&error];
    XCTAssertNil(error);
    
    NSString *decrypted = [[NSString alloc] initWithData:bobSessionMessage.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([plain isEqualToString:decrypted]);

    // Compare fingerprints
    NSData *localFingerprint = [self.aliceBox localFingerprint:&error];
    XCTAssertNil(error);
    NSData *remoteFingerprint = [bobSession remoteFingerprint];
    XCTAssertNotNil(localFingerprint);
    XCTAssertNotNil(remoteFingerprint);
    XCTAssertEqualObjects(localFingerprint, remoteFingerprint);

    localFingerprint = nil;
    remoteFingerprint = nil;
    
    localFingerprint = [self.bobBox localFingerprint:&error];
    XCTAssertNil(error);
    remoteFingerprint = [aliceSession remoteFingerprint];
    XCTAssertNotNil(localFingerprint);
    XCTAssertNotNil(remoteFingerprint);
    XCTAssertEqualObjects(localFingerprint, remoteFingerprint);
    
    [self.aliceBox closeSession:aliceSession];
    [self.bobBox closeSession:bobSession];
    
    aliceSession = [self.aliceBox sessionById:@"alice" error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(aliceSession);
    
    bobSession = [self.bobBox sessionById:@"bob" error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSession);
}

@end
