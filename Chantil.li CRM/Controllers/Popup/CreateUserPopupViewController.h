//
//  createUserPopupViewController.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 31/08/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BasePopupViewController.h"

@protocol CreateUserPopupViewControllerDelegate <NSObject>

- (void) didSaveUser:(NSDictionary *)user;

@end

@interface CreateUserPopupViewController : BasePopupViewController

@property (nonatomic, assign) id<CreateUserPopupViewControllerDelegate> delegate;

@end
