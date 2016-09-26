//
//  BasePopupViewController.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 14/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BasePopupViewController.h"

@interface BasePopupViewController ()

@end

@implementation BasePopupViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end
