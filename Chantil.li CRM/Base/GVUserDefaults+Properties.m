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
@dynamic odooHomePath;
@dynamic odooLoginPath;
@dynamic odooLoginJS;
@dynamic odooPOSPath;
@dynamic odooPOSJS;
@dynamic odooSession;
@dynamic odooSessionCookieName;

// User
@dynamic userList;
@dynamic userCurrent;

// Printer
@dynamic printer;

// Configuration
@dynamic isConfigured;
@dynamic isLocked;

- (NSDictionary *) setupDefaults
{
	return @{
			 @"odooProtocol": @"http://",
			 @"odooHost": @"localhost",
			 @"odooPort": @"8069",
			 @"odooHomePath": @"/web",
			 @"odooLoginPath": @"/web/login",
			 @"odooLoginJS": @"(function(){$(\"input[type='text']#login\").val(\"{user.email}\"),$(\"input[type='password']#password\").val(\"{user.password}\"),$(\"button[type='submit']\").click()})();",
			 @"odooPOSPath": @"/pos/web",
			 @"odooPOSJS": @"!function(){var a=setInterval(function(){if(\"\"!==$(\".receipt-screen .button.print\").text()){clearInterval(a);var b=$(\".receipt-screen .button.print\").parent(),c=$(\".receipt-screen .button.print\").clone();$(\".receipt-screen .button.print\").remove(),b.prepend(c),c.click(function(a){a.preventDefault();var b=posmodel.get_order().export_for_printing(),c=JSON.stringify(b),d=encodeURIComponent(c);location.href=\"crm://order?data=\"+d})}})}();",
			 @"odooSession": @0,
			 @"odooSessionCookieName": @"session_id",
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
