//
//  SelectUserPopupViewController.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 12/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BasePopupViewController.h"

@protocol SelectUserPopupViewControllerDelegate <NSObject>

- (void) didSelectUser:(NSDictionary *)user;

@end

@interface SelectUserPopupViewController : BasePopupViewController<UITableViewDelegate>

@property (nonatomic, assign) id<SelectUserPopupViewControllerDelegate> delegate;

@end
