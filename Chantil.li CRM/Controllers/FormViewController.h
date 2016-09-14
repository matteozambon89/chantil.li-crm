//
//  FormViewController.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 12/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "MenuDelegate.h"
#import "SelectUserPopupViewController.h"
#import "ABPadLockScreen.h"

@interface FormViewController : XLFormViewController <SelectUserPopupViewControllerDelegate, ABPadLockScreenViewControllerDelegate, MenuDelegate>

@property (nonatomic) BOOL ignoreCheckAppStatus;

@end
