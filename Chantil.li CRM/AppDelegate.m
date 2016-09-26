//
//  AppDelegate.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/2/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.

	// Fabric Setup
	[Fabric with:@[[Crashlytics class]]];
	
	// App Setup
	[Helper setupApp];
	
	// Init Process Pool
	self.processPool = [[WKProcessPool alloc] init];
	
	// Init WebView Configuration
	self.webViewConfig = [[WKWebViewConfiguration alloc] init];
	[self.webViewConfig setProcessPool:self.processPool];
	
	return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	
	[Helper lockApp:YES];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	[Helper lockApp:YES];
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	[[APIdleManager sharedInstance] checkAndReset];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Peripheral >>>
- (void) didUpdateBluetoothState:(CBManagerState)state
{
	SharedAppDelegate.bluetoothState = state;
	
	switch(state)
	{
		case CBCentralManagerStatePoweredOff:
		{
			[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterOff]];
			break;
		}
			
		case CBCentralManagerStateUnauthorized:
		{
			[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterError]];
			break;
		}
			
		case CBCentralManagerStateUnknown:
		{
			[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterError]];
			break;
		}
			
		case CBCentralManagerStatePoweredOn:
		{
			NSDictionary *printer = [GVUserDefaults standardUserDefaults].printer;
			if(!printer || ![printer valueForKey:@"uuid"])
			{
				[SharedAppDelegate.menuItemPrinter setIcon:[Helper imageNoPrinter]];
			}
			else
			{
				[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterOff]];
			}
			break;
		}
			
		case CBCentralManagerStateResetting:
		{
			[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterOff]];
			// Check what to do
			break;
		}
			
		case CBCentralManagerStateUnsupported:
		{
			[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterError]];
			break;
		}
	}
}
- (void) didFoundPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"printer.didFoundPeripheral" object:self userInfo:@{
																													@"peripheral": peripheral,
																													@"advertisementData": advertisementData,
																													@"RSSI": RSSI
																													}];
	
	[Helper printerTryReconnect:peripheral];
}
- (void) willConnectPeripheral:(CBPeripheral *)peripheral
{
	NSString *message = [NSString stringWithFormat:@"Connecting to %@...", peripheral.name];
	[FTIndicator showToastMessage:message];
}
- (void) didConnectPeripheral:(CBPeripheral *)peripheral
{
	NSString *message = [NSString stringWithFormat:@"Connected to %@!", peripheral.name];
	[FTIndicator showToastMessage:message];
	
	// Printer is now ON
	[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterOn]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"printer.didConnectPeripheral" object:self userInfo:@{
																													@"peripheral": peripheral
																													}];

}
- (void) didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSString *message = [error localizedDescription];
	[FTIndicator showToastMessage:message];
	
	// Printer is now ON
	[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterOn]];
}
- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral
{
	NSString *message = [NSString stringWithFormat:@"%@ signal lost", [peripheral name]];
	[FTIndicator showToastMessage:message];
	
	// Printer is now ON
	[SharedAppDelegate.menuItemPrinter setIcon:[Helper imagePrinterOff]];
}
- (void) didRecieveData:(NSData *)data
{
	
}
- (void) didSendData:(NSData *)data
{
	
}
// <<< Peripheral
@end
