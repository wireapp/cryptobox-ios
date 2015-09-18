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
    self.aliceBox = [self createBoxAndCheckAsserts:@"alice"];
    self.bobBox = [self createBoxAndCheckAsserts:@"bob"];
    
    CBPreKey *bobPreKey = [self generatePreKeyAndCheckAssertsWithLocation:1 box:self.bobBox];
    
    //Alice side
    NSError *error = nil;
    CBSession *aliceToBobSession = [self.aliceBox sessionWithId:@"sessionWithBob" fromPreKey:bobPreKey error:&error];
    XCTAssertNil(error, @"Error is not nil");
    XCTAssertNotNil(aliceToBobSession, @"Session creation from prekey failed");
    
    [aliceToBobSession save:&error];
    XCTAssertNil(error, @"Error is not nil");
    
    // Encrypt a message from alice to bob
    NSString *const plain = @"Hello Bob!";
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [aliceToBobSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipherData);
    XCTAssertNotEqual(plainData, cipherData);
    
    //Bob's side
    CBSessionMessage *bobToAliceSessionMessage = [self.bobBox sessionMessageWithId:@"sessionToAllice" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobToAliceSessionMessage);
    XCTAssertNotNil(bobToAliceSessionMessage.session);
    XCTAssertNotNil(bobToAliceSessionMessage.data);
    
    CBSession *bobToAliceSession = bobToAliceSessionMessage.session;

    [bobToAliceSession save:&error];
    XCTAssertNil(error);
    
    NSString *decrypted = [[NSString alloc] initWithData:bobToAliceSessionMessage.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([plain isEqualToString:decrypted]);

    // Compare fingerprints
    NSData *localFingerprint = [self.aliceBox localFingerprint:&error];
    XCTAssertNil(error);
    NSData *remoteFingerprint = [bobToAliceSession remoteFingerprint];
    XCTAssertNotNil(localFingerprint);
    XCTAssertNotNil(remoteFingerprint);
    XCTAssertEqualObjects(localFingerprint, remoteFingerprint);

    localFingerprint = nil;
    remoteFingerprint = nil;
    
    localFingerprint = [self.bobBox localFingerprint:&error];
    XCTAssertNil(error);
    remoteFingerprint = [aliceToBobSession remoteFingerprint];
    XCTAssertNotNil(localFingerprint);
    XCTAssertNotNil(remoteFingerprint);
    XCTAssertEqualObjects(localFingerprint, remoteFingerprint);
    
    [self.aliceBox closeSession:aliceToBobSession];
    [self.bobBox closeSession:bobToAliceSession];
    
    aliceToBobSession = [self.aliceBox sessionById:@"sessionWithBob" error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(aliceToBobSession);
    
    bobToAliceSession = [self.bobBox sessionById:@"sessionToAllice" error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobToAliceSession);
}

@end
