// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import "CBVector.h"



@interface CBVector (Internal)

- (nonnull instancetype)initWithCBoxVecRef:(nonnull CBoxVecRef)vector;

+ (nonnull instancetype)vectorWithCBoxVecRef:(nonnull CBoxVecRef)vector;

- (nonnull uint8_t *)dataArray;

- (size_t)length;

@end
