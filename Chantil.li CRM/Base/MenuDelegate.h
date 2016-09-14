//
//  MenuDelegate.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 12/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCFloatingActionButton-Swift.h"

@protocol MenuDelegate <NSObject>

- (void) didTapOnItem:(KCFloatingActionButtonItem *)item;

@end
