//
//  SelectPrinterPopupViewController.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 14/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BasePopupViewController.h"

@protocol SelectPrinterPopupViewControllerDelegate <NSObject>

- (void) didSelectPrinter:(NSDictionary *)printer;

@end

@interface SelectPrinterPopupViewController : BasePopupViewController<UITableViewDelegate>

@property (nonatomic, assign) id<SelectPrinterPopupViewControllerDelegate> delegate;

@end
