//
//  CBTestCase.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <XCTest/XCTest.h>

@class CBCryptoBox;



@interface CBTestCase : XCTestCase

- (CBCryptoBox *)createBoxAndCheckAsserts;

@end
