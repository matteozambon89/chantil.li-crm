//
//  ViewController.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/2/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BrowserViewController : BaseViewController <LockScreenDelegate, KINWebBrowserDelegate>

@property (nonatomic) BOOL startWithPOS;

@end

