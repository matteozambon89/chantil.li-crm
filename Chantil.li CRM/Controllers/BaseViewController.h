//
//  BaseViewController.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 12/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuDelegate.h"
#import "SelectUserPopupViewController.h"
#import "ABPadLockScreen.h"

@interface BaseViewController : UIViewController <SelectUserPopupViewControllerDelegate, ABPadLockScreenViewControllerDelegate, MenuDelegate>

@property (nonatomic) BOOL ignoreCheckAppStatus;

- (void) checkAppStatus;

@end
