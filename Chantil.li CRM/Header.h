//
//  Header.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/2/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#define LOG 1

#ifdef __OBJC__
// SharedAppDelegate
#import "AppDelegate.h"
#define SharedAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#endif

#ifndef Header_h
#define Header_h

// Constants
#import "Constants.h"

// Helpers
#import "Helper.h"

// BLEPrinter
#import "BLEPrinter.h"

// Fabric
#import <Fabric/Fabric.h>
// Crahlytics
#import <Crashlytics/Crashlytics.h>

// KINWebBrowser - https://cocoapods.org/pods/KINWebBrowser
#import "KINWebBrowserViewController.h"

// MTBBarcodeScanner - https://cocoapods.org/pods/MTBBarcodeScanner
#import "MTBBarcodeScanner.h"

// GVUserDefaults - https://cocoapods.org/pods/GVUserDefaults
#import "GVUserDefaults+Properties.h"

// SVProgressHUD - https://cocoapods.org/pods/SVProgressHUD
#import "SVProgressHUD.h"

// STPopup - https://cocoapods.org/pods/STPopup
#import "STPopup.h"

// KCFloatingActionButton - http://cocoapods.org/pods/kcfloatingactionbutton
#import "KCFloatingActionButton-Swift.h"

// FontAwesomeKit
#import <FontAwesomeKit/FontAwesomeKit.h>

// XLForm - https://cocoapods.org/pods/XLForm
#import "XLForm.h"

// ABPadLockScreen - https://cocoapods.org/pods/ABPadLockScreen
#import "ABPadLockScreen.h"

// SKSpinner - https://cocoapods.org/pods/SKSpinner
#import "SKSpinner.h"

// ApIdleManager - https://cocoapods.org/pods/ApIdleManager
#import "ApIdleManager.h"

#endif /* Header_h */
