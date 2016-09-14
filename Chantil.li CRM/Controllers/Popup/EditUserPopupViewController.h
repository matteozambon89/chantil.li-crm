//
//  EditUserPopupViewController.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 01/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BasePopupViewController.h"

@protocol EditUserPopupViewControllerDelegate <NSObject>

- (void) didUpdateUser:(NSDictionary *)user;
- (void) didDeleteUser:(NSDictionary *)user;

@end

@interface EditUserPopupViewController : BasePopupViewController

@property (nonatomic, assign) id<EditUserPopupViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *user;

@end
