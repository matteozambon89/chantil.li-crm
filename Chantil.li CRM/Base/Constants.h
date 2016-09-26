//
//  Constants.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

// Segues
FOUNDATION_EXPORT NSString *const segueSplash;
FOUNDATION_EXPORT NSString *const segueSettings;
FOUNDATION_EXPORT NSString *const segueBrowser;
FOUNDATION_EXPORT NSString *const segueLogin;

// Colors
FOUNDATION_EXPORT float const colorPrimaryR;
FOUNDATION_EXPORT float const colorPrimaryG;
FOUNDATION_EXPORT float const colorPrimaryB;
FOUNDATION_EXPORT float const colorPrimaryA;

// Keys
FOUNDATION_EXPORT NSString *const keysUser;

// Settings
FOUNDATION_EXPORT int const settingsUserSectionIndex;

// Form
FOUNDATION_EXPORT NSString *const formId;
FOUNDATION_EXPORT NSString *const formName;
FOUNDATION_EXPORT NSString *const formEmail;
FOUNDATION_EXPORT NSString *const formPassword;
FOUNDATION_EXPORT NSString *const formShortCode;
FOUNDATION_EXPORT NSString *const formProtocol;
FOUNDATION_EXPORT NSString *const formHost;
FOUNDATION_EXPORT NSString *const formPort;
FOUNDATION_EXPORT NSString *const formOdooHomePath;
FOUNDATION_EXPORT NSString *const formOdooLoginPath;
FOUNDATION_EXPORT NSString *const formOdooLoginJS;
FOUNDATION_EXPORT NSString *const formOdooPOSPath;
FOUNDATION_EXPORT NSString *const formOdooPOSJS;
FOUNDATION_EXPORT NSString *const formOdooSessionCookieName;

// Printer
FOUNDATION_EXPORT int const printerMaxCharPerLine;

@end
