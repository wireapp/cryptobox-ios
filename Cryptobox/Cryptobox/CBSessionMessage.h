//
//  CBSessionMessage.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 11.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBSession;



@interface CBSessionMessage : NSObject

@property (nonatomic, readonly, nonnull) CBSession *session;
@property (nonatomic, readonly, nullable) NSData *message;

- (nonnull instancetype)initWithSession:(nonnull CBSession *)session message:(nullable NSData *)message;

@end
