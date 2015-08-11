//
//  CBSessionMessage.m
//  Cryptobox
//
//  Created by Andreas Kompanez on 11.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBSessionMessage.h"

@interface CBSessionMessage ()

@property (nonatomic, readwrite, nonnull) CBSession *session;
@property (nonatomic, readwrite, nullable) NSData *message;

@end

@implementation CBSessionMessage

- (nonnull instancetype)initWithSession:(CBSession *)session message:(NSData *)message
{
    self = [super init];
    if (self) {
        self.session = session;
        self.message = message;
    }
    return self;
}

@end
