//
//  AppDelegate.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/2/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEPrinter.h"
#import "STPopup.h"
#import "MenuDelegate.h"
#import "LockScreenDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BLEPrinterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BLEPrinter *printer;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) STPopupController *popupController;
@property (assign, nonatomic) id<MenuDelegate> menuDelegate;
@property (assign, nonatomic) id<LockScreenDelegate> lockScreenDelegate;

@end

