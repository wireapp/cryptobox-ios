//
//  CBSession+Internal.h
//  Cryptobox
//
//  Created by Andreas Kompanez on 16.08.15.
//  Copyright (c) 2015 Cryptobox. All rights reserved.
//

#import "CBSession.h"



@interface CBSession (Internal)

- (nonnull instancetype)initWithCBoxSessionRef:(nonnull CBoxSessionRef)session sessionId:(nonnull NSString *)sid;

- (void)close;

@end