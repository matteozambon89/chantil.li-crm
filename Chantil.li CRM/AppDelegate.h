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
#import "KCFloatingActionButton-Swift.h"
#import <WebKit/WebKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, BLEPrinterDelegate>

// Window
@property (strong, nonatomic) UIWindow *window;

// Bluetooth - Printer
@property (strong, nonatomic) BLEPrinter *printer;
// Bluetooth - Peripheral
@property (strong, nonatomic) CBPeripheral *peripheral;
// Bluetooth - Peripherals
@property (strong, nonatomic) NSMutableDictionary *peripherals;
// Bluetooth - State
@property (nonatomic) CBManagerState bluetoothState;
// Popup
@property (strong, nonatomic) STPopupController *popupController;
// Menu
@property (strong, nonatomic) KCFloatingActionButtonItem *menuItemPrinter;
// Menu - Delegate
@property (assign, nonatomic) id<MenuDelegate> menuDelegate;
// Lock Screen - Delegate
@property (assign, nonatomic) id<LockScreenDelegate> lockScreenDelegate;

@property (strong, nonatomic) WKProcessPool *processPool;
@property (strong, nonatomic) WKWebViewConfiguration *webViewConfig;

@end

