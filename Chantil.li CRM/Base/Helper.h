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

// Odoo Helpers >>>
+ (BOOL) isOdooPortCustom:(NSString *)odooPort withProtocol:(NSString *)odooProtocol;
+ (NSURL *) odooUrlWithPath:(NSString *)path;
+ (NSURL *) odooLoginUrl;
+ (NSString *) odooLoginJS;
// <<< Odoo Helpers

// Color Helpers >>>
+ (UIColor *) colorPrimary;
// <<< Color Helpers

// Image Helpers >>>
+ (UIImage *) imageMenu;
+ (UIImage *) imageSettings;
+ (UIImage *) imageEduk;
+ (UIImage *) imageOdoo;
+ (UIImage *) imageUser;
// <<< Image Helpers

// Setup Helpers >>>
+ (void) setupMenu;
+ (void) setupPeripheralWithDelegate:(id)delegate;
+ (void) setupApp;
// <<< Setup Helpers

@end
