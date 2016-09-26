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
#import "SelectPrinterPopupViewController.h"
#import "ABPadLockScreen.h"

@interface BaseViewController : UIViewController <SelectUserPopupViewControllerDelegate, SelectPrinterPopupViewControllerDelegate, ABPadLockScreenViewControllerDelegate, MenuDelegate>

@property (nonatomic) BOOL ignoreCheckAppStatus;
@property (nonatomic) BOOL openOdooPOS;

- (void) checkAppStatus;

@end
