//
//  GVUserDefaults+Properties.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "GVUserDefaults+Properties.h"

@interface GVUserDefaults()

@end

@implementation GVUserDefaults (Properties)

// Odoo
@dynamic odooProtocol;
@dynamic odooHost;
@dynamic odooPort;
@dynamic odooLoginPath;
@dynamic odooLoginJS;

// User
@dynamic userList;
@dynamic userCurrent;

// Printer
@dynamic printerUUID;

// Configuration
@dynamic isConfigured;
@dynamic isLocked;

- (NSDictionary *) setupDefaults
{
	return @{
			 @"odooProtocol": @"http://",
			 @"odooHost": @"localhost",
			 @"odooPort": @"8069",
			 @"odooLoginPath": @"/web/login",
			 @"odooLoginJS": @"function loginFromApp(){$(\"input[type='text']#login\").val(\"{user.email}\"); $(\"input[type='password']#password\").val(\"{user.password}\"); $(\"button[type='submit']\").click(); return true;} loginFromApp();",
			 @"userList": @[],
			 @"userCurrent": @"",
			 @"isConfigured": @NO,
			 @"isLocked": @NO
    };
}

- (NSString *) transformKey:(NSString *)key
{
	key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
	return [NSString stringWithFormat:@"NSUserDefault%@", key];
}

@end
