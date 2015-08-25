// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

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
    [bobBox closeSession:bobSession];    
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
    [bobBox closeSession:bobSession];

    // TODO: Figure out how to handle NSAssert's and the exception handler call
//    bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipher error:&error];
//    XCTAssertNotNil(error);
//    XCTAssertTrue(error.code == CBErrorCodeInvalidMessage);
}


@end
