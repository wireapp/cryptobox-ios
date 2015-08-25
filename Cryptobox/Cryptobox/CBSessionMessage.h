// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>

@class CBSession;



@interface CBSessionMessage : NSObject

@property (nonatomic, readonly, nonnull) CBSession *session;
@property (nonatomic, readonly, nullable) NSData *data;

- (nonnull instancetype)initWithSession:(nonnull CBSession *)session data:(nullable NSData *)data;

@end
