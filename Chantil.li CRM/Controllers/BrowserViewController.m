//
//  ViewController.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/2/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BrowserViewController.h"
#import "SVProgressHUD.h"

@interface BrowserViewController ()

// WebBrowser
@property (strong, nonatomic) KINWebBrowserViewController *webBrowser;
@property (nonatomic) BOOL webBrowserNeedsInit;

@end

@implementation BrowserViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	// Initialize WebBrowser
	self.webBrowser = [KINWebBrowserViewController webBrowser];
	self.webBrowser.showsURLInNavigationBar = NO;
	self.webBrowser.showsPageTitleInNavigationBar = NO;
	self.webBrowser.actionButtonHidden = YES;
	[self.webBrowser setDelegate:self];

	// Flag system saying Web Browser needs to be initialized
	self.webBrowserNeedsInit = YES;
	
	// Say to Navigation Controller to move to WebBrowser
	[self.navigationController pushViewController:self.webBrowser animated:NO];

	// If is requested Login
	if(self.runLogin == YES)
	{
		// Show ProgressHUD
		[SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
		[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];

		[SVProgressHUD show];

		// Create odooLoginUrl request with Cache and 60 second of max Timeout
		NSURLRequest *request = [NSURLRequest requestWithURL:[Helper odooLoginUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];

		// Load request into WebBrowser
		[self.webBrowser loadRequest:request];
	}
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// KINWebBrowser Delegate >>>

// webBrowser start loading
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL
{
	// If WebBrowser needs to be initialized
	if(self.webBrowserNeedsInit == YES)
	{
		// Say it's the first and the last time to run that
		self.webBrowserNeedsInit = NO;
		// Hide the NavigationBar
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		// Hide the ToolBar
		[self.navigationController setToolbarHidden:YES animated:YES];

		// Load the progressView outside of Navigation Bar
		[self.webBrowser.progressView setFrame:CGRectMake(0, 0, self.webBrowser.view.frame.size.width, self.webBrowser.progressView.frame.size.height)];
		[self.webBrowser.view addSubview:self.webBrowser.progressView];
		
		// Display the menu
		[[KCFABManager defaultInstance] show:YES];
	}
}

// webBrowser finish loading
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL
{
	NSString *currentUrlString = [URL absoluteString];
	NSString *odooLoginUrlString = [[Helper odooLoginUrl] absoluteString];

	if(self.runLogin == YES)
	{
		self.runLogin = NO;

		[self.webBrowser.wkWebView evaluateJavaScript:[Helper odooLoginJS] completionHandler:^(NSString *result, NSError *error){
			if(error != nil)
			{
				[SVProgressHUD showErrorWithStatus:[error localizedDescription]];

				[self.navigationController popToRootViewControllerAnimated:YES];

				return;
			}
		}];
	}
	else if(![currentUrlString isEqualToString:odooLoginUrlString])
	{
		[SVProgressHUD dismiss];
	}
}

// webBrowser fail to load
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error
{
	[SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

// <<< KINWebBrowser Delegate

@end
