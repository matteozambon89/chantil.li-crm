//
//  SettingsViewController.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormViewController.h"
#import "CreateUserPopupViewController.h"
#import "EditUserPopupViewController.h"
#import "SelectPrinterPopupViewController.h"

@interface SettingsViewController : FormViewController <LockScreenDelegate, XLFormDescriptorDelegate, CreateUserPopupViewControllerDelegate, EditUserPopupViewControllerDelegate, SelectPrinterPopupViewControllerDelegate>

@end
