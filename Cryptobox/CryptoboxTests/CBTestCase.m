// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import "CBTestCase.h"

#import "Cryptobox.h"

NSURL *__nullable CBCreateTemporaryDirectoryAndReturnURL(NSString *name)
{
    NSError *error = nil;
    NSURL *directoryURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] stringByAppendingPathComponent:name] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        return nil;
    }
    
    return directoryURL;
}



@implementation CBTestCase

- (nullable CBCryptoBox *)createBoxAndCheckAsserts:(NSString *__nonnull)userName
{
    NSURL *url = CBCreateTemporaryDirectoryAndReturnURL(userName);
    NSError *error = nil;
    CBCryptoBox *box = [CBCryptoBox cryptoBoxWithPathURL:url error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(box, @"Failed to create alice box");
    
    return box;
}


- (NSArray *)generatePreKeysAndCheckAssertsWithRange:(NSRange)range box:(CBCryptoBox *)box
{
    NSError *error = nil;
    NSArray *keys = [box generatePreKeys:range error:&error];
    XCTAssertNotNil(keys);
    XCTAssertTrue(keys.count == range.length);
    return keys;
}

- (CBPreKey *)generatePreKeyAndCheckAssertsWithLocation:(NSUInteger)location box:(CBCryptoBox *)box
{
    NSArray *keys = [self generatePreKeysAndCheckAssertsWithRange:(NSRange){location, 1} box:box];
    XCTAssertTrue(keys.count == 1, @"Wrong amount of keys generated");
    CBPreKey *preKey = keys[0];
    XCTAssertNotNil(preKey);
    return preKey;
}

@end
