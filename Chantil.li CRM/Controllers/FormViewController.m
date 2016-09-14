//
//  FormViewController.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 12/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "FormViewController.h"
#import "SettingsViewController.h"
#import "BrowserViewController.h"

@interface FormViewController ()

@property (strong, nonatomic) ABPadLockScreenViewController *lockScreenViewController;
@property (strong, nonatomic) NSDictionary *user;

@end

@implementation FormViewController

- (instancetype) init
{
	self = [super init];
	
	if(self)
	{
		self.ignoreCheckAppStatus = NO;
	}
	
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Dismiss SVProgressHUD
	[SVProgressHUD dismiss];
	
	SharedAppDelegate.menuDelegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	if(!self.ignoreCheckAppStatus)
	{
		[self checkAppStatus];
	}
	
	[APIdleManager sharedInstance].onTimeout = ^(void){
		[Helper lockApp:YES];
		
		if(!self.ignoreCheckAppStatus)
		{
			[self checkAppStatus];
		}
	};
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UIResponder *) nextResponder
{
	[[APIdleManager sharedInstance] didReceiveInput];
	//Any other previous functionality you had
	
	return [super nextResponder];
}

// This will get called too before the view appears
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Called after
	// [self performSegueWithIdentifier:@"{segue.identifier}" sender:sender];
	
	// Get segue.identifier
	NSString *segueIdentifier = [segue identifier];
	
	if([segueIdentifier isEqualToString:segueSettings])
	{
		// Get SettingsViewController
		SettingsViewController *settingsVC = [segue destinationViewController];
		
		// Pass parameters
		// [settingsVC set{property.name}:{value}];
		
		// Define if App is Configured
		BOOL isConfigured = [GVUserDefaults standardUserDefaults].isConfigured;
		
		// Check App Status must be ignored in case App isn't Configured
		if(!isConfigured)
		{
			settingsVC.ignoreCheckAppStatus = YES;
		}
	}
	else if([segueIdentifier isEqualToString:segueBrowser])
	{
		// Get BrowserViewController
		BrowserViewController *browserVC = [segue destinationViewController];
		
		// Pass parameters
		// [browserVC set{property.name}:{value}];
		browserVC.runLogin = YES;
	}
}

- (void) applicationWillEnterForeground:(NSNotification *)notification
{
	if(!self.ignoreCheckAppStatus)
	{
		[self checkAppStatus];
	}
}

- (void) didTapOnItem:(KCFloatingActionButtonItem *)item
{
	if([item.title isEqualToString:@"Odoo"])
	{
		@try
		{
			[self performSegueWithIdentifier:segueBrowser sender:self];
		}
		@catch(NSException *e)
		{
		}
	}
	else if([item.title isEqualToString:@"EDUK"])
	{
		@try
		{
			[self performSegueWithIdentifier:segueBrowser sender:self];
		}
		@catch(NSException *e)
		{
		}
	}
	else if([item.title isEqualToString:@"Settings"])
	{
		@try
		{
			[self performSegueWithIdentifier:segueSettings sender:self];
		}
		@catch(NSException *e)
		{
		}
	}
	else if([item.title isEqualToString:@"Change User"])
	{
		@try
		{
			[Helper userLogout];
			
			[self performSegueWithIdentifier:segueSplash sender:self];
		}
		@catch(NSException *e)
		{
			// It's the SplashViewController
		}
	}
}

- (void) checkAppStatus
{
	// Define if App is Configured
	BOOL isConfigured = [GVUserDefaults standardUserDefaults].isConfigured;
	// Define if App is Locked
	BOOL isLocked = [GVUserDefaults standardUserDefaults].isLocked;
	
	// Get User Current
	NSDictionary *userCurrent = [Helper userCurrent];
	
	// App must be configured
	if(!isConfigured)
	{
		@try
		{
			[self performSegueWithIdentifier:segueSettings sender:self];
		}
		@catch(NSException *e)
		{
			// It's the SettingsViewController
		}
	}
	// A User needs to be chosen
	else if(userCurrent == nil)
	{
		[self showSelectUserPopup];
	}
	// App cannot be Locked
	else if(isLocked)
	{
		[self didSelectUser:userCurrent];
	}
}

- (void) showSelectUserPopup
{
	SelectUserPopupViewController *popupViewController = [SelectUserPopupViewController new];
	popupViewController.delegate = self;
	
	SharedAppDelegate.popupController = nil;
	SharedAppDelegate.popupController = [[STPopupController alloc] initWithRootViewController:popupViewController];
	[SharedAppDelegate.popupController setNavigationBarHidden:YES];
	if (NSClassFromString(@"UIBlurEffect"))
	{
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
		SharedAppDelegate.popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	}
	[SharedAppDelegate.popupController.containerView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController.backgroundView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController presentInViewController:self];
}

- (void) didSelectUser:(NSDictionary *)user
{
	[SharedAppDelegate.lockScreenDelegate willPromptUnlock];
	
	// Set current user
	self.user = user;
	
	// Create a LockScreen View Controller
	self.lockScreenViewController = [[ABPadLockScreenViewController alloc] initWithDelegate:self complexPin:YES];
	
	// Set attempts
	[self.lockScreenViewController setAllowedAttempts:3];
	
	// Set feedbacks
	self.lockScreenViewController.tapSoundEnabled = YES;
	self.lockScreenViewController.errorVibrateEnabled = YES;
	
	// If you have possibility of Blur use it
	if (NSClassFromString(@"UIBlurEffect"))
	{
		[[ABPadLockScreenView appearance] setLabelColor:[Helper colorPrimary]];
		[[ABPadButton appearance] setBackgroundColor:[UIColor clearColor]];
		[[ABPadButton appearance] setBorderColor:[Helper colorPrimary]];
		[[ABPadButton appearance] setSelectedColor:[Helper colorPrimary]];
		[[ABPadButton appearance] setTextColor:[Helper colorPrimary]];
		[[ABPadButton appearance] setHightlightedTextColor:[UIColor whiteColor]];
		[[ABPinSelectionView appearance] setSelectedColor:[Helper colorPrimary]];
		
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
		UIVisualEffectView *blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		UIVisualEffectView *viewInducingVibrancy = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		[blurredView.contentView addSubview:viewInducingVibrancy];
		
		[self.lockScreenViewController setBackgroundView:blurredView];
	}
	// Otherwise just use standard flat colors
	else
	{
		[[ABPadLockScreenView appearance] setBackgroundColor:[Helper colorPrimary]];
		[[ABPadLockScreenView appearance] setLabelColor:[UIColor whiteColor]];
		[[ABPadButton appearance] setBackgroundColor:[UIColor clearColor]];
		[[ABPadButton appearance] setBorderColor:[UIColor whiteColor]];
		[[ABPadButton appearance] setSelectedColor:[UIColor whiteColor]];
		[[ABPadButton appearance] setTextColor:[UIColor whiteColor]];
		[[ABPadButton appearance] setHightlightedTextColor:[Helper colorPrimary]];
		[[ABPinSelectionView appearance] setSelectedColor:[UIColor whiteColor]];
		
		[self.lockScreenViewController setBackgroundView:[UIView new]];
	}
	
	// Display as Modal
	self.lockScreenViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.lockScreenViewController.providesPresentationContextTransitionStyle = YES;
	self.lockScreenViewController.definesPresentationContext = YES;
	[self.lockScreenViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
	
	// Present the LockScreen
	[self presentViewController:self.lockScreenViewController animated:NO completion:nil];
}

- (BOOL) padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController validatePin:(NSString*)pin;
{
	NSString *userShortCode = [NSString stringWithFormat:@"%d", [(NSNumber *)[self.user valueForKey:@"shortCode"] intValue]];
	
	return [userShortCode isEqualToString:pin];
}

- (void) unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	// Success
	[Helper userLogin:self.user];
	
	[SharedAppDelegate.lockScreenDelegate didUnlockUser:self.user];
	
	self.lockScreenViewController = nil;
}

- (void) unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
	NSLog(@"Failed attempt number %ld with pin: %@", (long)attemptNumber, falsePin);
	
	// Failed
	if(self.lockScreenViewController.remainingAttempts == 0)
	{
		[self dismissViewControllerAnimated:YES completion:nil];
		
		[Helper userLogout];
		
		@try
		{
			[self performSegueWithIdentifier:segueSplash sender:self];
		}
		@catch(NSException *e)
		{
			// It's the SplashViewController
			[self showSelectUserPopup];
		}
		
		self.lockScreenViewController = nil;
	}
}

- (void) unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController
{
	NSLog(@"Pin entry cancelled");
	
	// Cancel
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[Helper userLogout];
	
	@try
	{
		[self performSegueWithIdentifier:segueSplash sender:self];
	}
	@catch(NSException *e)
	{
		// It's the SplashViewController
		[self showSelectUserPopup];
	}
	
	self.lockScreenViewController = nil;
}

@end
