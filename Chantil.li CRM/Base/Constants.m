//
//  Constants.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "Constants.h"

@implementation Constants

// Segues
NSString *const segueSplash = @"splashSegue";
NSString *const segueSettings = @"settingsSegue";
NSString *const segueBrowser = @"browserSegue";

// Colors
float const colorPrimaryR = 220.0f/255.0f;
float const colorPrimaryG = 29.0/255.0f;
float const colorPrimaryB = 87.0f/255.0f;
float const colorPrimaryA = 1.0f;

// Keys
NSString *const keysUser = @"_id,name,odooUsername,odooPassword";

// Settings
int const settingsUserSectionIndex = 1;

// Form
NSString *const formId = @"id";
NSString *const formName = @"name";
NSString *const formEmail = @"email";
NSString *const formPassword = @"password";
NSString *const formShortCode = @"formShortCode";
NSString *const formProtocol = @"protocol";
NSString *const formHost = @"host";
NSString *const formPort = @"port";
NSString *const formOdooLoginPath = @"odoo-login-path";
NSString *const formOdooLoginJS = @"odoo-login-js";

@end
