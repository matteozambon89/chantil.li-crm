//
//  AppDelegate.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/2/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.

	// Fabric Setup
	[Fabric with:@[[Crashlytics class]]];
	
	// App Setup
	[Helper setupApp];
	
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
- (void) didFoundPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	//	SharedAppDelegate.peripheral = peripheral;
	
	//	[SharedAppDelegate.printer connectPeripheral:SharedAppDelegate.peripheral];
	//	[SharedAppDelegate.printer stopScanning];
}
- (void) didConnectPeripheral:(CBPeripheral *)peripheral
{
	
}
- (void) didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	[SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}
- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral
{
	NSString *msg = [NSString stringWithFormat:@"%@ signal lost", [peripheral name]];
	
	[SVProgressHUD showInfoWithStatus:msg];
}
- (void) didRecieveData:(NSData *)data
{
	
}
- (void) didSendData:(NSData *)data
{
	
}
// <<< Peripheral
@end
