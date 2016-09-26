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
	
	if([user valueForKey:@"welcomeMessage"] != nil)
	{
		[FTIndicator showToastMessage:[user valueForKey:@"welcomeMessage"]];
		
		[user setValue:nil forKey:@"welcomeMessage"];
	}
	
	[self lockApp:NO];
	
	[self setupPeripheralToSearch];
}

+ (void) userLogout
{
	[GVUserDefaults standardUserDefaults].userCurrent = @"";
	
	[self odooSessionStop];
	
	[CrashlyticsKit setUserIdentifier:nil];
	[CrashlyticsKit setUserEmail:nil];
	[CrashlyticsKit setUserName:nil];
	
	[self lockApp:NO];
}

+ (NSDictionary *) printerCurrent
{
	return [GVUserDefaults standardUserDefaults].printer;
}

+ (void) printerSelect:(NSDictionary *)printer
{
	NSMutableDictionary *printerM = [printer mutableCopy];
	
	if([printerM valueForKey:@"cbperipheral"])
	{
		[printerM setValue:nil forKey:@"cbperipheral"];
	}
	
	[GVUserDefaults standardUserDefaults].printer = (NSDictionary *)printerM;
}

+ (void) printerConnect:(CBPeripheral *)peripheral disconnectPrevious:(BOOL)disconnectPrevious
{
	if(!peripheral)
	{
		NSString *message = @"You're trying to connect to an unexisting printer!";
		[FTIndicator showToastMessage:message];
		
		return;
	}
	
	if(disconnectPrevious)
	{
		if(SharedAppDelegate.peripheral)
		{
			[SharedAppDelegate.printer disconnectPeripheral:SharedAppDelegate.peripheral];
		}
	}
	
	SharedAppDelegate.peripheral = peripheral;
	
	[SharedAppDelegate.printer connectPeripheral:SharedAppDelegate.peripheral];
	[SharedAppDelegate.printer stopScanning];
}

+ (void) printerTryReconnect:(CBPeripheral *)peripheral
{
	if([self printerCurrent])
	{
		NSDictionary *printer = [self printerCurrent];
		NSString *printerUuid = [printer valueForKey:@"uuid"];
		
		if([[peripheral.identifier UUIDString] isEqualToString:printerUuid])
		{
			[self printerConnect:peripheral disconnectPrevious:NO];
		}
	}
}

+ (void) printerTest
{
	[SharedAppDelegate.printer sendMessage:@"Printer test passed\nHave a wonderful day!"];
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

+ (NSString *) odooHost
{
	// Get Odoo details >>>
	// Host
	NSString *odooHost = [GVUserDefaults standardUserDefaults].odooHost;
	// <<< Get Odoo details
	
	return odooHost;
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

+ (NSURL *) odooHomeUrl
{
	// Get Odoo details >>>
	// Home
	NSString *odooHomePath = [GVUserDefaults standardUserDefaults].odooHomePath;
	
	// <<< Get Odoo details
	
	return [self odooUrlWithPath:odooHomePath];
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

+ (NSURL *) odooPOSUrl
{
	// Get Odoo details >>>
	// POS
	NSString *odooPOSPath = [GVUserDefaults standardUserDefaults].odooPOSPath;
	
	// <<< Get Odoo details
	
	return [self odooUrlWithPath:odooPOSPath];
}

+ (NSString *) odooPOSJS
{
	// Get Odoo details >>>
	// POSJS
	NSString *odooPOSJS = [GVUserDefaults standardUserDefaults].odooPOSJS;
	// <<< Get Odoo details
	
	return odooPOSJS;
}

+ (NSString *) odooSessionCookieName
{
	// Get Odoo details >>>
	// SessionCookieName
	NSString *odooSessionCookieName = [GVUserDefaults standardUserDefaults].odooSessionCookieName;
	// <<< Get Odoo details
	
	return odooSessionCookieName;
}

+ (NSNumber *) odooSession
{
	// Get Odoo details >>>
	// Session
	NSNumber *odooSession = [GVUserDefaults standardUserDefaults].odooSession;
	// <<< Get Odoo details
	
	return odooSession;
}

+ (BOOL) isOdooSessionValid
{
	NSNumber *odooSession = [self odooSession];
	
	if([odooSession intValue] == 0)
	{
		return NO;
	}
	
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
	if([odooSession intValue] < [[NSNumber numberWithDouble:timestamp] intValue])
	{
		return NO;
	}
	
	// Get Cookie Storage
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	if([cookieStorage.cookies count] > 0)
	{
		for(NSHTTPCookie *cookie in cookieStorage.cookies)
		{
			// Get Cookie Domain
			NSString *cookieDomain = [cookie domain];
			// Get Odoo Host
			NSString *odooHost = [self odooHost];
			
			// Delete just Cookies from Odoo
			if([cookieDomain isEqualToString:odooHost])
			{
				// Get Cookie Name
				NSString *cookieName = [cookie name];
				// Get Odoo Session Cookie Name
				NSString *odooSessionCookieName = [self odooSessionCookieName];
				
				// Ensure Odoo Session Cookie exists
				if([cookieName isEqualToString:odooSessionCookieName])
				{
					return YES;
				}
			}
		}
		
		return NO;
	}
	
	return YES;
}

+ (NSNumber *) odooSessionLength
{
	// 90 days
	return [NSNumber numberWithInt:(60*60*24*90)];
}

+ (void) odooSessionStart;
{
	// Get Cookie Storage
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	if([cookieStorage.cookies count] > 0)
	{
		for(NSHTTPCookie *cookie in cookieStorage.cookies)
		{
			// Get Cookie Domain
			NSString *cookieDomain = [cookie domain];
			// Get Odoo Host
			NSString *odooHost = [self odooHost];
			
			// Delete just Cookies from Odoo
			if([cookieDomain isEqualToString:odooHost])
			{
				// Get Cookie Name
				NSString *cookieName = [cookie name];
				// Get Odoo Session Cookie Name
				NSString *odooSessionCookieName = [self odooSessionCookieName];
				
				if([cookieName isEqualToString:odooSessionCookieName])
				{
					NSDate *expireDate = [cookie expiresDate];
					
					NSTimeInterval expireTimestamp = [expireDate timeIntervalSince1970];
					NSNumber *odooSession = [NSNumber numberWithDouble:expireTimestamp];
					
					[GVUserDefaults standardUserDefaults].odooSession = odooSession;
				}
			}
		}
	}
	else
	{
		NSDate *now = [[NSDate alloc] init];
		NSTimeInterval expireTimestamp = [now timeIntervalSince1970];
		
		int expiredAt = [[NSNumber numberWithDouble:expireTimestamp] intValue];
		int odooSessionLength = [[self odooSessionLength] intValue];
		int odooSessionInt = expiredAt + odooSessionLength;
		
		NSNumber *odooSession = [NSNumber numberWithInt:odooSessionInt];
		
		[GVUserDefaults standardUserDefaults].odooSession = odooSession;
	}
}

+ (void) odooSessionStop
{
	[GVUserDefaults standardUserDefaults].odooSession = [NSNumber numberWithInt:0];
	
	// Get Cookie Storage
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for(NSHTTPCookie *cookie in cookieStorage.cookies)
	{
		// Get Cookie Domain
		NSString *cookieDomain = [cookie domain];
		// Get Odoo Host
		NSString *odooHost = [self odooHost];
		
		// Delete just Cookies from Odoo
		if([cookieDomain isEqualToString:odooHost])
		{
			[cookieStorage deleteCookie:cookie];
		}
	}
}

+ (UIColor *) colorPrimary
{
	UIColor *primary = [UIColor colorWithRed:colorPrimaryR green:colorPrimaryG blue:colorPrimaryB alpha:colorPrimaryA];
	
	return primary;
}

+ (NSInteger) blurPrimary
{
	return UIBlurEffectStyleExtraLight;
}

+ (UIImage *) imageMenu
{
	FAKIonIcons *icon = [FAKIonIcons naviconIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imageSettings
{
	FAKIonIcons *icon = [FAKIonIcons iosGearOutlineIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imageEduk
{
	FAKIonIcons *icon = [FAKIonIcons universityIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imagePOS
{
	FAKIonIcons *icon = [FAKIonIcons iosCartOutlineIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imageOdoo
{
	FAKIonIcons *icon = [FAKIonIcons iosListOutlineIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}


+ (UIImage *) imageUser
{
	FAKIonIcons *icon = [FAKIonIcons iosPersonOutlineIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imagePrinterError
{
	FAKIonIcons *icon = [FAKIonIcons alertCircledIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imageNoPrinter
{
	FAKIonIcons *icon = [FAKIonIcons toggleIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imagePrinterOff
{
	FAKIonIcons *icon = [FAKIonIcons toggleIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imagePrinterOn
{
	FAKIonIcons *icon = [FAKIonIcons iosPrinterOutlineIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (UIImage *) imageLock
{
	FAKIonIcons *icon = [FAKIonIcons iosLockedOutlineIconWithSize:30];
	[icon addAttribute:NSForegroundColorAttributeName value:[Helper colorPrimary]];
	UIImage *iconImage = [icon imageWithSize:CGSizeMake(30, 30)];
	
	return iconImage;
}

+ (void) menuShow
{
	[[KCFABManager defaultInstance] show:YES];
}

+ (void) menuHide
{
	[[KCFABManager defaultInstance] hide:YES];
}

+ (void) setupProgressHUD
{
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
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
	// Button Item > Lock
	[[[KCFABManager defaultInstance] getButton] addItem:@"Lock" icon:[self imageLock] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	// Button Item > Setting
	[[[KCFABManager defaultInstance] getButton] addItem:@"Settings" icon:[self imageSettings] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	// Button Item > Printer
	SharedAppDelegate.menuItemPrinter = [[[KCFABManager defaultInstance] getButton] addItem:@"Printer" icon:[self imageNoPrinter] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	// Button Item > EDUK
	 // [[[KCFABManager defaultInstance] getButton] addItem:@"EDUK" icon:[self imageEduk] handler:^(KCFloatingActionButtonItem *item) {
	 // 	[SharedAppDelegate.menuDelegate didTapOnItem:item];
	 // }];
	// Button Item > Sales Manager
	[[[KCFABManager defaultInstance] getButton] addItem:@"Sales Manager" icon:[self imageOdoo] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	// Button Item > POS
	[[[KCFABManager defaultInstance] getButton] addItem:@"POS" icon:[self imagePOS] handler:^(KCFloatingActionButtonItem *item) {
		[SharedAppDelegate.menuDelegate didTapOnItem:item];
	}];
	
	// Action Menu hidden
	[self menuHide];
}

+ (void) setupPeripheralToSearch
{
	SharedAppDelegate.printer = [[BLEPrinter alloc] init];
	SharedAppDelegate.printer.delegate = SharedAppDelegate;
}

+ (void) setupApp
{
	// Progress
	[Helper setupProgressHUD];
	
	// Action Menu
	[Helper setupMenu];
}

+ (BOOL) isConfigured
{
	NSArray *userList = [GVUserDefaults standardUserDefaults].userList;
	if([userList count] == 0)
	{
		[GVUserDefaults standardUserDefaults].isConfigured = NO;
	}
	
	return [GVUserDefaults standardUserDefaults].isConfigured;
}

+ (void) orderPrint:(NSDictionary *)order
{
	[SVProgressHUD showWithStatus:@"Printing..."];
	
	/*
	 ******************************
	          Chantil.li
		Amor em forma de docinhos
			   Loja SJC
	 
	 25/09/2016, 14:41:08
	 Ordem: ordem00003-001-0003
	 Usuario: Administrator
	 
	 Brigadeiro de
	 Caipirinha            R$ 5.00
	 10% desconto         -R$ 0.50
	 
	 Subtotal:             R$ 5.00
	 Desconto:             R$ 0.50
	 Total:                R$ 4.50
	 
	 Cash (BRL)            R$ 5.00
	 
	 Troco:                R$ 0.50
	 
			   Nosso Site
		   https://chantil.li
			  Fale Conosco
	       contato@chantil.li
	           Nossa Loja
		     Rua Sei La, 123
			  CEP 13836-12
	 */
	
	NSString *companyName = [order valueForKeyPath:@"company.name"];
	NSString *header = [order valueForKey:@"header"];
	NSString *shopName = [order valueForKeyPath:@"shop.name"];
	NSString *orderName = [order valueForKey:@"name"];
	NSString *orderDate = [order valueForKeyPath:@"date.localestring"];
	NSString *cashier = [order valueForKey:@"cashier"];
	NSArray *orderLines = [order valueForKey:@"orderlines"];
	NSString *currency = [order valueForKeyPath:@"currency.symbol"];
	NSNumber *subtotal = [order valueForKey:@"subtotal"];
	NSNumber *totalDiscount = [order valueForKey:@"total_discount"];
	NSNumber *totalPaid = [order valueForKey:@"total_paid"];
	NSArray *paymentLines = [order valueForKey:@"paymentlines"];
	NSNumber *change = [order valueForKey:@"change"];
	NSString *companyEmail = [order valueForKeyPath:@"company.email"];
	NSString *companyWebsite = [order valueForKeyPath:@"company.website"];
	NSString *companyPhone = [order valueForKeyPath:@"company.phone"];
	NSString *footer = [order valueForKey:@"footer"];

	NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setMaximumFractionDigits:2];
	[priceFormatter setMinimumFractionDigits:2];
	[priceFormatter setPositiveFormat:[NSString stringWithFormat:@"%@ ##0.00", currency]];
	[priceFormatter setNegativeFormat:[NSString stringWithFormat:@"-%@ ##0.00", currency]];
	
	NSNumberFormatter *quantityFormatter = [[NSNumberFormatter alloc] init];
	[quantityFormatter setMaximumFractionDigits:0];
	[quantityFormatter setMinimumFractionDigits:0];
	[quantityFormatter setPositiveFormat:@"##0"];
	[quantityFormatter setNegativeFormat:@"##0"];

	NSString *subtotalFormatted = [priceFormatter stringFromNumber:subtotal];
	NSString *totalDiscountFormatted = [priceFormatter stringFromNumber:totalDiscount];
	NSString *totalPaidFormatted = [priceFormatter stringFromNumber:totalPaid];
	NSString *changeFormatted = [priceFormatter stringFromNumber:change];

	NSString *message = @"";

	// Company Name
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:companyName]];
	// Header
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:header withDivisor:YES]];
	// Shop Name
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:shopName]];
	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];
	// Order Date
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToLeft:orderDate]];
	// Order Name
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTitle:@"Ordem" andText:orderName]];
	// Cachier
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTitle:@"Usuário" andText:cashier]];
	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];

	// OrderLines
	for(NSDictionary *orderLine in orderLines)
	{
		// OrderLine - Quantity
		NSNumber *quantity = [orderLine valueForKey:@"quantity"];
		// OrderLine - Product Name
		NSString *productName = [orderLine valueForKey:@"product_name"];
		// OrderLine - Price
		NSNumber *price = [orderLine valueForKey:@"price"];
		// Total Price
		double priceTotalValue = [price doubleValue] * [quantity doubleValue];
		NSNumber *priceTotal = [NSNumber numberWithDouble:priceTotalValue];
		// OrderLine - Discount
		NSNumber *discount = [orderLine valueForKey:@"discount"];
		// Price Formatted
		NSString *priceFormatted = [priceFormatter stringFromNumber:priceTotal];
		
		// Discount String
		NSString *discountString = [NSString stringWithFormat:@"%@%@ %@", [discount stringValue], @"%", @"desconto"];
		// Discount Value
		double discountValue = -1 * [priceTotal doubleValue] * [discount doubleValue] / 100;
		// Discount Display
		NSNumber *discountDisplay = [NSNumber numberWithDouble:discountValue];
		// Discount Display Formatted
		NSString *discountDisplayFormatted = [priceFormatter stringFromNumber:discountDisplay];
		
		NSString *productNameWithQuantity = [NSString stringWithFormat:@"%@ %@", [quantityFormatter stringFromNumber:quantity], productName];
		
		// Product Name - Price Formatted
		message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																							 productNameWithQuantity,
																							 priceFormatted
																							 ]]];
		if([discount intValue] > 0)
		{
			// Discount
			message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																								 discountString,
																								 discountDisplayFormatted
																								 ]]];
		}
	}

	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];
	// Subtotal
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																						 @"Subtotal:",
																						 subtotalFormatted
																						 ]]];
	// totalDiscount
	if([totalDiscount intValue] > 0)
	{
		message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																							 @"Desconto:",
																							 totalDiscountFormatted
																							 ]]];
	}
	// Total
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																						 @"Total:",
																						 totalPaidFormatted
																						 ]]];

	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];

	// OrderLines
	for(NSDictionary *paymentLine in paymentLines)
	{
		// PaymentLine - Journal
		NSString *journal = [paymentLine valueForKey:@"journal"];
		// PaymentLine - Amount
		NSNumber *amount = [paymentLine valueForKey:@"amount"];
		// Amount Formatted
		NSString *amountFormatted = [priceFormatter stringFromNumber:amount];

		// Product Name - Price Formatted
		message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																							 journal,
																							 amountFormatted
																							 ]]];
	}

	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];
	// Change
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithColumns:@[
																						 @"Troco:",
																						 changeFormatted
																						 ]]];
	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];
	// Company Phone
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:@"Telephone"]];
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:companyPhone]];
	// Company Website
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:@"Nosso Site"]];
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:companyWebsite]];
	// Company Email
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:@"Fale Conosco"]];
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:companyEmail]];
	// Space Line
	message = [NSString stringWithFormat:@"%@\n", message];
	// Footer
	message = [NSString stringWithFormat:@"%@%@", message, [BLEPrinter lineWithTextToCenter:footer withDivisor:YES]];

	[SharedAppDelegate.printer sendMessage:message];
	
	[SVProgressHUD showSuccessWithStatus:@"Printed"];
}

@end
