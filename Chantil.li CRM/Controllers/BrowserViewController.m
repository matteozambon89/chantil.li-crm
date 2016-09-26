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
// ProgressBar check
@property (nonatomic) BOOL hasProgressBar;
// Is Login in process
@property (nonatomic) BOOL isLoginInProcess;
// Is Login JS injected
@property (nonatomic) BOOL isLoginJSInjected;
// Is Printing Order
@property (nonatomic) BOOL isPrintingOrder;

@end

@implementation BrowserViewController

- (void) viewDidLoad
{
	SharedAppDelegate.lockScreenDelegate = self;
	
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	// Initialize WebBrowser
	self.webBrowser = [KINWebBrowserViewController webBrowserWithConfiguration:SharedAppDelegate.webViewConfig];
	self.webBrowser = [KINWebBrowserViewController webBrowser];
	self.webBrowser.showsURLInNavigationBar = NO;
	self.webBrowser.showsPageTitleInNavigationBar = NO;
	self.webBrowser.actionButtonHidden = YES;
	self.webBrowser.barTintColor = [Helper colorPrimary];
	[self.webBrowser setDelegate:self];
	
	// Say to Navigation Controller to move to WebBrowser
	[self.navigationController pushViewController:self.webBrowser animated:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) stopLoadingRequest
{
	if(self.webBrowser.wkWebView)
	{
		if([self.webBrowser.wkWebView isLoading])
		{
			[self.webBrowser.wkWebView stopLoading];
		}
	}
	else if(self.webBrowser.uiWebView)
	{
		if([self.webBrowser.uiWebView isLoading])
		{
			[self.webBrowser.uiWebView stopLoading];
		}
	}
}

// Odoo Handlers >>>

// Odoo Session Handler
- (void) checkOdooSession
{
	[self checkOdooSession:NO];
}
- (void) checkOdooSession:(BOOL)overrideCurrentURL
{
	NSURL *currentURL = self.webBrowser.wkWebView.URL;
	NSString *currentURLString = [currentURL absoluteString];
	
	// Check if User's Odoo Session is Valid
	if(![Helper isOdooSessionValid])
	{
		// Show ProgressHUD
		[SVProgressHUD show];
		
		// Create odooLoginUrl request with Cache and 60 second of max Timeout
		NSURLRequest *request = [NSURLRequest requestWithURL:[Helper odooLoginUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
		
		// Set login as in process
		self.isLoginInProcess = YES;
		
		// Load request into WebBrowser
		[self stopLoadingRequest];
		[self.webBrowser loadRequest:request];
	}
	else if(!currentURLString || overrideCurrentURL)
	{
		NSURL *startWithURL = [Helper odooHomeUrl];
		if(self.startWithPOS)
		{
			startWithURL = [Helper odooPOSUrl];
		}

		// Create odooLoginUrl request with Cache and 60 second of max Timeout
		NSURLRequest *request = [NSURLRequest requestWithURL:startWithURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
		
		// Set login as in process
		self.isLoginInProcess = NO;
		
		// Load request into WebBrowser
		[self stopLoadingRequest];
		[self.webBrowser loadRequest:request];
	}
}

// <<< Odoo Handlers

// Lock Screen Delegates >>>

// Unlock completed
- (void) didUnlockUser:(NSDictionary *)user
{
	// Action Menu visible
	[Helper menuShow];
	
	// Check Odoo Session
	[self checkOdooSession];
}

// Lock will be Prompted
- (void) willPromptUnlock
{
}

// Locked after Timeout
- (void) lockScreenAtTimeout:(NSTimer *)timer
{
	[Helper lockApp:YES];
	
	[super checkAppStatus];
}

// <<< Lock Screen Delegates

// Menu Delegate >>>

- (void) didTapOnItem:(KCFloatingActionButtonItem *)item
{
	if([item.title isEqualToString:@"POS"])
	{
		self.startWithPOS = YES;
		
		[self checkOdooSession:YES];
	}
	else if([item.title isEqualToString:@"Sales Manager"])
	{
		self.startWithPOS = NO;
		
		[self checkOdooSession:YES];
	}
	else
	{
		[self stopLoadingRequest];
		[super didTapOnItem:item];
	}
}

// <<< Menu Delegate

// KINWebBrowser Delegate >>>

// Web Browser view will appear
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser viewWillAppear:(BOOL)animated
{
	// Load the progressView outside of Navigation Bar
	CGRect frame = self.webBrowser.progressView.frame;
	
	[self.webBrowser.progressView setFrame:CGRectMake(0, 0, frame.size.width, 20)];
	if(self.webBrowser.wkWebView)
	{
		[self.webBrowser.wkWebView addSubview:self.webBrowser.progressView];
	}
	else if(self.webBrowser.uiWebView)
	{
		[self.webBrowser.uiWebView addSubview:self.webBrowser.progressView];
	}
	else
	{
		[self.webBrowser.view addSubview:self.webBrowser.progressView];
	}
	
	// Set Progress Bar Tint color
	[self.webBrowser.progressView setTintColor:[Helper colorPrimary]];
	
	// Hide the NavigationBar
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	// Hide the ToolBar
	[self.navigationController setToolbarHidden:YES animated:NO];
	
	// Show Menu
	[Helper menuShow];
	
	// Check Odoo Session
	[self checkOdooSession];

}

// Web Browser view will appear
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser viewWillDisappear:(BOOL)animated
{
	[self stopLoadingRequest];
}

// Web Browser start loading
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL
{
	// Set Progress Bar Tint color
	[self.webBrowser.progressView setTintColor:[Helper colorPrimary]];
	
	NSString *currentUrlString = [URL absoluteString];
	NSString *crmOrderUrlString = @"crm://order?data=";
	
	if([currentUrlString containsString:crmOrderUrlString])
	{
		self.isPrintingOrder = YES;
		
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
		NSArray *queryItems = urlComponents.queryItems;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"data"];
		NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
		NSString *orderEncoded = queryItem.value;
		
		NSString *orderJson = [orderEncoded stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSData *orderData = [orderJson dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary *order = [NSJSONSerialization JSONObjectWithData:orderData options:0 error:nil];
		
		[Helper orderPrint:order];
	}
}

// Web Browser finish loading
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL
{
	// Set Progress Bar Tint color
	[self.webBrowser.progressView setTintColor:[Helper colorPrimary]];
	
	NSString *currentUrlString = [Helper normalizedPath:[URL absoluteString]];
	NSString *odooLoginUrlString = [Helper normalizedPath:[[Helper odooLoginUrl] absoluteString]];
	NSString *odooPOSUrlString = [Helper normalizedPath:[[Helper odooPOSUrl] absoluteString]];

	if([currentUrlString isEqualToString:odooLoginUrlString] && self.isLoginInProcess && !self.isLoginJSInjected)
	{
		self.isLoginJSInjected = YES;
		
		NSString *odooLoginJSString = [Helper odooLoginJS];
		
		if(self.webBrowser.wkWebView)
		{
			[self.webBrowser.wkWebView evaluateJavaScript:odooLoginJSString completionHandler:^(NSString *result, NSError *error){
				if(error != nil)
				{
					[SVProgressHUD showErrorWithStatus:[error localizedDescription]];
					
					return;
				}
			}];
		}
		else if(self.webBrowser.uiWebView)
		{
			[self.webBrowser.uiWebView stringByEvaluatingJavaScriptFromString:odooLoginJSString];
		}
	}
	else if(![currentUrlString isEqualToString:odooLoginUrlString] && self.isLoginInProcess == YES)
	{
		self.isLoginInProcess = NO;
		
		[SVProgressHUD dismiss];
		
		[Helper odooSessionStart];
	}
	else if([currentUrlString isEqualToString:odooPOSUrlString])
	{
		NSString *odooPOSJSString = [Helper odooPOSJS];
		
		if(self.webBrowser.wkWebView)
		{
			[self.webBrowser.wkWebView evaluateJavaScript:odooPOSJSString completionHandler:^(NSString *result, NSError *error){
				if(error != nil)
				{
					[SVProgressHUD showErrorWithStatus:[error localizedDescription]];
					
					return;
				}
			}];
		}
		else if(self.webBrowser.uiWebView)
		{
			[self.webBrowser.uiWebView stringByEvaluatingJavaScriptFromString:odooPOSJSString];
		}
	}
}

// Web Browser fail to load
- (void) webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL error:(NSError *)error
{
	if(self.isPrintingOrder)
	{
		return;
	}
	
	[SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

// <<< KINWebBrowser Delegate

@end
