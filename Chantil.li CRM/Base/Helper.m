//
//  Helper.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (void) resetConfigToDefault
{
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+ (NSString *) normalizedPath:(NSString *)path
{
	NSError *error = nil;

	NSRegularExpression *regexStart = [NSRegularExpression regularExpressionWithPattern:@"^/" options:NSRegularExpressionCaseInsensitive error:&error];
	NSString *normalizedPath = [regexStart stringByReplacingMatchesInString:path options:0 range:NSMakeRange(0, [path length]) withTemplate:@""];

	NSRegularExpression *regexEnd = [NSRegularExpression regularExpressionWithPattern:@"/$" options:NSRegularExpressionCaseInsensitive error:&error];
	normalizedPath = [regexEnd stringByReplacingMatchesInString:normalizedPath options:0 range:NSMakeRange(0, [normalizedPath length]) withTemplate:@""];

	return normalizedPath;
}

+ (void) lockApp:(BOOL)isLocked
{
	[GVUserDefaults standardUserDefaults].isLocked = isLocked;
}

+ (NSDictionary *) userCurrent
{
	NSString *userUuid = [GVUserDefaults standardUserDefaults].userCurrent;
	
	if([userUuid isEqualToString:@""])
	{
		return nil;
	}
	
	return [self userWithUuid:userUuid];
}

+ (NSDictionary *) userWithUuid:(NSString *)uuid
{
	NSArray *usersArr = [GVUserDefaults standardUserDefaults].userList;
	for(NSDictionary *user in usersArr)
	{
		if([[user valueForKey:@"uuid"] isEqualToString:uuid])
		{
			return user;
		}
	}
	
	return nil;
}

+ (NSDictionary *) userWithEmail:(NSString *)email
{
	NSArray *usersArr = [GVUserDefaults standardUserDefaults].userList;
	for(NSDictionary *user in usersArr)
	{
		if([[user valueForKey:@"email"] isEqualToString:email])
		{
			return user;
		}
	}
	
	return nil;
}

+ (void) userLogin:(NSDictionary *)user
{
	[GVUserDefaults standardUserDefaults].userCurrent = [user valueForKey:@"uuid"];
	
	[CrashlyticsKit setUserIdentifier:[user valueForKey:@"uuid"]];
	[CrashlyticsKit setUserEmail:[user valueForKey:@"email"]];
	[CrashlyticsKit setUserName:[user valueForKey:@"name"]];
	
	[self lockApp:NO];
}

+ (void) userLogout
{
	[GVUserDefaults standardUserDefaults].userCurrent = @"";
	
	[CrashlyticsKit setUserIdentifier:nil];
	[CrashlyticsKit setUserEmail:nil];
	[CrashlyticsKit setUserName:nil];
	
	[self lockApp:NO];
}

+ (BOOL) isOdooPortCustom:(NSString *)odooPort withProtocol:(NSString *)odooProtocol
{
	// TRUE if odooPort isn't passed or is empty string or isn't 80 nor 443
	return (
			odooPort == nil ||
			[odooPort isEqualToString:@""] ||
			!([odooProtocol isEqualToString:@"http://"] && [odooPort isEqualToString:@"80"]) ||
			!([odooProtocol isEqualToString:@"https://"] && [odooPort isEqualToString:@"443"])
			);
}

+ (NSURL *) odooUrlWithPath:(NSString *)path
{
	// Get Odoo details >>>
	// Protocol (http | https)
	NSString *odooProtocol = [GVUserDefaults standardUserDefaults].odooProtocol;

	// Host
	NSString *odooHost = [GVUserDefaults standardUserDefaults].odooHost;

	// Port
	NSString *odooPort = [GVUserDefaults standardUserDefaults].odooPort;
	// <<< Get Odoo details

	// Setup Odoo URL >>>
	NSString *odooUrlString = [NSString stringWithFormat:@"%@%@", odooProtocol, odooHost];

	// Add Port in case it's custom
	if([self isOdooPortCustom:odooPort withProtocol:odooProtocol])
	{
		odooUrlString = [NSString stringWithFormat:@"%@:%@", odooUrlString, odooPort];
	}

	// Normalize URL Path
	NSString *normalizedPath = [self normalizedPath:path];

	// Add Path to Odoo URL
	odooUrlString = [NSString stringWithFormat:@"%@/%@", odooUrlString, normalizedPath];

	NSURL *odooUrl = [[NSURL alloc] initWithString:odooUrlString];
	// <<< Setup Odoo URL

	return odooUrl;
}

+ (NSURL *) odooLoginUrl
{
	// Get Odoo details >>>
	// Login
	NSString *odooLoginPath = [GVUserDefaults standardUserDefaults].odooLoginPath;

	// <<< Get Odoo details

	return [self odooUrlWithPath:odooLoginPath];
}

+ (NSString *) odooLoginJS
{
	// Get User details >>>
	NSString *userUuid = [GVUserDefaults standardUserDefaults].userCurrent;

	NSObject *user = [self userWithUuid:userUuid];

	NSString *userEmail = [user valueForKey:@"email"];
	NSString *userPassword = [user valueForKey:@"password"];
	// <<< Get User details

	// Get Odoo details >>>
	// LoginJS
	NSString *odooLoginJS = [GVUserDefaults standardUserDefaults].odooLoginJS;

	// <<< Get Odoo details

	odooLoginJS = [odooLoginJS stringByReplacingOccurrencesOfString:@"{user.email}" withString:userEmail];
	odooLoginJS = [odooLoginJS stringByReplacingOccurrencesOfString:@"{user.password}" withString:userPassword];

	return odooLoginJS;
}

+ (UIColor *) colorPrimary
{
	UIColor *primary = [UIColor colorWithRed:colorPrimaryR green:colorPrimaryG blue:colorPrimaryB alpha:colorPrimaryA];
	
	return primary;
}

+ (UIImage *) imageMenu
{
	FAKIonIcons *navIcon = [FAKIonIcons naviconIconWithSize:30];
	[navIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
	UIImage *navImage = [navIcon imageWithSize:CGSizeMake(30, 30)];
	
	return navImage;
}

+ (UIImage *) imageSettings
{
	FAKIonIcons *gearOutline = [FAKIonIcons iosGearOutlineIconWithSize:30];
	[gearOutline addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *gearOutlineImage = [gearOutline imageWithSize:CGSizeMake(30, 30)];
	
	return gearOutlineImage;
}

+ (UIImage *) imageEduk
{
	FAKIonIcons *university = [FAKIonIcons universityIconWithSize:30];
	[university addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *universityImage = [university imageWithSize:CGSizeMake(30, 30)];
	
	return universityImage;
}

+ (UIImage *) imageOdoo
{
	FAKIonIcons *cartOutline = [FAKIonIcons iosCartOutlineIconWithSize:30];
	[cartOutline addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *cartOutlineImage = [cartOutline imageWithSize:CGSizeMake(30, 30)];
	
	return cartOutlineImage;
}

+ (UIImage *) imageUser
{
	FAKIonIcons *personOutline = [FAKIonIcons iosPersonOutlineIconWithSize:30];
	[personOutline addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *personOutlineImage = [personOutline imageWithSize:CGSizeMake(30, 30)];
	
	return personOutlineImage;
}

+ (void) setupMenu
{	
	// Button Icon
	[[[KCFABManager defaultInstance] getButton] setButtonImage:[Helper imageMenu]];
	// Button Color
	[[[KCFABManager defaultInstance] getButton] setButtonColor:[Helper colorPrimary]];
	// Button Rotaion
	[[[KCFABManager defaultInstance] getButton] setRotationDegrees:90.0f];
	
	[[[KCFABManager defaultInstance] getButton] setItems:@[]];
	
	// Button Item > Change User
	[[[KCFABManager defaultInstance] getButton] addItem:@"Change User" icon:[self imageUser] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	// Button Item > Setting
	[[[KCFABManager defaultInstance] getButton] addItem:@"Settings" icon:[self imageSettings] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	// Button Item > EDUK
	 // [[[KCFABManager defaultInstance] getButton] addItem:@"EDUK" icon:[self imageEduk] handler:^(KCFloatingActionButtonItem *item) {
	 // 	[SharedAppDelegate.menuDelegate didTapOnItem:item];
	 // }];
	// Button Item > Odoo
	[[[KCFABManager defaultInstance] getButton] addItem:@"Odoo" icon:[self imageOdoo] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	
	// Action Menu hidden
	[[KCFABManager defaultInstance] hide:YES];
}

+ (void) setupPeripheralWithDelegate:(id)delegate
{
	SharedAppDelegate.printer = [[BLEPrinter alloc] init];
	SharedAppDelegate.printer.delegate = delegate;
	[SharedAppDelegate.printer stopScanning];
}

+ (void) setupApp
{
	// Peripheral
	[Helper setupPeripheralWithDelegate:self];
	
	// Action Menu
	[Helper setupMenu];
	
	NSArray *userList = [GVUserDefaults standardUserDefaults].userList;
	if([userList count] == 0)
	{
		[GVUserDefaults standardUserDefaults].isConfigured = NO;
	}
}

@end
