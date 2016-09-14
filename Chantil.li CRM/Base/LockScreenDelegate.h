//
//  LockScreenDelegate.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 14/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LockScreenDelegate<NSObject>

- (void) willPromptUnlock;
- (void) didUnlockUser:(NSDictionary *)user;

@end
