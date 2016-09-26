//
//  SplashViewController.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation SplashViewController

- (void) viewDidLoad
{
	SharedAppDelegate.lockScreenDelegate = self;

	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib

	// [Helper resetConfigToDefault];

	self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(lockScreenAtTimeout:) userInfo:nil repeats:NO];
}

- (void) viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	// Hide the NavigationBar
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	// Hide the ToolBar
	[self.navigationController setToolbarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.timer invalidate];
	self.timer = nil;
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) didUnlockUser:(NSDictionary *)user
{
	[self performSegueWithIdentifier:segueBrowser sender:self];
}

- (void) willPromptUnlock
{
	[self.timer invalidate];
	self.timer = nil;
}

- (void) lockScreenAtTimeout:(NSTimer *)timer
{
	[Helper lockApp:YES];

	[self checkAppStatus];
}

@end
