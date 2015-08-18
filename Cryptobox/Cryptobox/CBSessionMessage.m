// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import "CBSessionMessage.h"

@interface CBSessionMessage ()

@property (nonatomic, readwrite, nonnull) CBSession *session;
@property (nonatomic, readwrite, nullable) NSData *data;

@end

@implementation CBSessionMessage

- (nonnull instancetype)initWithSession:(nonnull CBSession *)session data:(nullable NSData *)data;
{
    self = [super init];
    if (self) {
        self.session = session;
        self.data = data;
    }
    return self;
}

@end
