//
//  CBSession.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 04.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBTypes.h"



@interface CBSession : NSObject

- (BOOL)save:(NSError *__nullable * __nullable)error;

- (void)close;

- (BOOL)isClosed;

- (nullable NSData *)encrypt:(nonnull NSData *)plain error:(NSError *__nullable * __nullable)error;

- (nullable NSData *)decrypt:(nonnull NSData *)cipher error:(NSError *__nullable * __nullable)error;

@end


@interface CBSession (Internal)

- (nonnull instancetype)initWithCBoxSessionRef:(nonnull CBoxSessionRef)session;

@end