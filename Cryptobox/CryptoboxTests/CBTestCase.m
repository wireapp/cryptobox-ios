//
//  CBTestCase.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBTestCase.h"

#import "Cryptobox.h"



@implementation CBTestCase

- (CBCryptoBox *)createBoxAndCheckAsserts
{
    NSURL *url = CBCreateTemporaryDirectoryAndReturnURL();
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:url error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(box, @"Failed to create alice box");
    
    return box;
}

@end
