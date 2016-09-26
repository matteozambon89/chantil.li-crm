//
//  GVUserDefaults+Properties.h
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (Properties)

@property (nonatomic, weak) NSString *odooProtocol;
@property (nonatomic, weak) NSString *odooHost;
@property (nonatomic, weak) NSString *odooPort;
@property (nonatomic, weak) NSString *odooHomePath;
@property (nonatomic, weak) NSString *odooLoginPath;
@property (nonatomic, weak) NSString *odooLoginJS;
@property (nonatomic, weak) NSString *odooPOSPath;
@property (nonatomic, weak) NSString *odooPOSJS;
@property (nonatomic, weak) NSNumber *odooSession;
@property (nonatomic, weak) NSString *odooSessionCookieName;

@property (nonatomic, weak) NSArray *userList;
@property (nonatomic, weak) NSString *userCurrent;

@property (nonatomic, weak) NSDictionary *printer;

@property (nonatomic) BOOL isConfigured;
@property (nonatomic) BOOL isLocked;

@end
