//
//  Helper.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (void) resetConfigToDefault;
+ (NSString *) normalizedPath:(NSString *)path;
+ (void) lockApp:(BOOL)isLocked;

// User Helpers >>>
+ (NSDictionary *) userCurrent;
+ (NSDictionary *) userWithUuid:(NSString *)uuid;
+ (NSDictionary *) userWithEmail:(NSString *)email;
+ (void) userLogin:(NSDictionary *)user;
+ (void) userLogout;
// <<< User Helpers

// Printer Helpers >>>
+ (NSDictionary *) printerCurrent;
+ (void) printerSelect:(NSDictionary *)printer;
+ (void) printerConnect:(CBPeripheral *)peripheral disconnectPrevious:(BOOL)disconnectPrevious;
+ (void) printerTryReconnect:(CBPeripheral *)peripheral;
+ (void) printerTest;
// <<< Printer Helpers

// Odoo Helpers >>>
+ (BOOL) isOdooPortCustom:(NSString *)odooPort withProtocol:(NSString *)odooProtocol;
+ (NSString *) odooHost;
+ (NSURL *) odooUrlWithPath:(NSString *)path;
+ (NSURL *) odooHomeUrl;
+ (NSURL *) odooLoginUrl;
+ (NSString *) odooLoginJS;
+ (NSURL *) odooPOSUrl;
+ (NSString *) odooPOSJS;
+ (NSString *) odooSessionCookieName;
+ (NSNumber *) odooSessionLength;
+ (BOOL) isOdooSessionValid;
+ (void) odooSessionStart;
+ (void) odooSessionStop;
// <<< Odoo Helpers

// Color Helpers >>>
+ (UIColor *) colorPrimary;
// <<< Color Helpers

// Blur Helper >>>
+ (NSInteger) blurPrimary;
// <<< Blur Helper

// Image Helpers >>>
+ (UIImage *) imageMenu;
+ (UIImage *) imageSettings;
+ (UIImage *) imageEduk;
+ (UIImage *) imagePOS;
+ (UIImage *) imageOdoo;
+ (UIImage *) imageUser;
+ (UIImage *) imagePrinterError;
+ (UIImage *) imageNoPrinter;
+ (UIImage *) imagePrinterOn;
+ (UIImage *) imagePrinterOff;
+ (UIImage *) imageLock;
// <<< Image Helpers

// Menu Helpers >>>
+ (void) menuShow;
+ (void) menuHide;
// <<< Menu Helpers

// Setup Helpers >>>
+ (void) setupMenu;
+ (void) setupPeripheralToSearch;
+ (void) setupApp;
+ (BOOL) isConfigured;
// <<< Setup Helpers

// Order Helpers >>>
+ (void) orderPrint:(NSDictionary *)order;
// <<< Order Helpers

@end
