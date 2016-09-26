//
//  EditUserPopupViewController.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 01/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "EditUserPopupViewController.h"

@interface EditUserPopupViewController ()

@property (strong, nonatomic) XLFormDescriptor *form;
@property (nonatomic) NSUInteger userIndex;

@end

@implementation EditUserPopupViewController

@synthesize form;
@synthesize delegate;

- (instancetype) init
{
	self = [super init];
	
	if(self)
	{
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(validateForm:)];
		
		self.contentSizeInPopup = CGSizeMake(300, 325);
		self.landscapeContentSizeInPopup = CGSizeMake(600, 400);
		
		[self initializeForm];
	}
	
	return self;
}

- (void) initializeForm
{
	// Implementation details covered in the next section.
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;
	
	self.form = [XLFormDescriptor formDescriptorWithTitle:@"Edit User"];
	
	// Section - Your Details
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Your Details"];
	[self.form addFormSection:section];
	
	// Id
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formId rowType:XLFormRowDescriptorTypeInfo title:@"Id"];
	row.value = [[NSUUID UUID] UUIDString];
	[section addFormRow:row];
	
	// Name
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formName rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"Your name" forKey:@"textField.placeholder"];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Section - Odoo Details
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Odoo Details"];
	[self.form addFormSection:section];
	
	// Email
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formEmail rowType:XLFormRowDescriptorTypeEmail];
	[row.cellConfigAtConfigure setObject:@"hello@world.net" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormValidator emailValidator]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Password
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formPassword rowType:XLFormRowDescriptorTypePassword];
	[row.cellConfigAtConfigure setObject:@"it-is-a-secret" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"At least 6, max 32 characters" regex:@"^.{6,32}$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Short Code
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formShortCode rowType:XLFormRowDescriptorTypeInteger];
	[row.cellConfigAtConfigure setObject:@"1234" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Exactly 4 digits" regex:@"^[0-9]{4}$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Section - Options
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Options"];
	[self.form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"delete-user" rowType:XLFormRowDescriptorTypeButton title:@"Delete User"];
	[row.cellConfig setValue:[UIColor redColor] forKey:@"textColor"];
	row.action.formBlock = ^(XLFormRowDescriptor * sender){
		[self deselectFormRow:sender];
		
		NSArray *userList = [GVUserDefaults standardUserDefaults].userList;
		
		NSDictionary *user = [userList objectAtIndex:self.userIndex];
		
		NSMutableArray *userListM = [userList mutableCopy];
		
		[userListM removeObjectAtIndex:self.userIndex];
		
		[GVUserDefaults standardUserDefaults].userList = (NSArray *)userListM;
		
		[delegate didDeleteUser:user];
		
		[self dismissViewControllerAnimated:YES completion:^{
			[SVProgressHUD showSuccessWithStatus:@"User has been deleted!"];
		}];
	};
	[section addFormRow:row];
}

- (void) storeNewUser
{
	NSString *uuid = (NSString*)[self.form formRowWithTag:formId].value;
	NSString *name = (NSString*)[self.form formRowWithTag:formName].value;
	NSString *email = (NSString*)[self.form formRowWithTag:formEmail].value;
	NSString *password = (NSString*)[self.form formRowWithTag:formPassword].value;
	NSNumber *shortCode = (NSNumber*)[self.form formRowWithTag:formShortCode].value;
	
	NSArray *userList = [GVUserDefaults standardUserDefaults].userList;
	for(NSDictionary *user in userList)
	{
		NSString *userEmail = [user valueForKey:@"email"];
		
		if([userEmail isEqualToString:email] && ![[user valueForKey:@"uuid"] isEqual:uuid])
		{
			UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:[self.form formRowWithTag:formEmail]]];
			[self animateCell:cell];
			
			[SVProgressHUD showErrorWithStatus:@"Email already exists"];
			return;
		}
	}
	
	NSDictionary *userToSave = @{
								 @"uuid": uuid,
								 @"name": name,
								 @"email": email,
								 @"password": password,
								 @"shortCode": shortCode
								 };
	
	NSMutableArray *userListM = [userList mutableCopy];
	[userListM setObject:userToSave atIndexedSubscript:self.userIndex];
	
	[GVUserDefaults standardUserDefaults].userList = (NSArray *)userListM;
	
	[delegate didUpdateUser:[userListM objectAtIndex:self.userIndex]];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// `self.user` must be set
	if(self.user == nil)
	{
		[self dismissViewControllerAnimated:YES completion:^{
			[SVProgressHUD showErrorWithStatus:@"Something went wrong!"];
		}];
	}
	// Index will be set to -1 as default to express "No user selected"
	self.userIndex = -1;
	
	// Find `self.user` in `userList`
	NSArray *userList = [GVUserDefaults standardUserDefaults].userList;
	for(NSDictionary *user in userList)
	{
		self.userIndex++;
		
		if([[self.user valueForKey:@"uuid"] isEqual:[user valueForKey:@"uuid"]])
		{
			break;
		}
	}
	
	// User not found
	if(self.userIndex == -1)
	{
		[self dismissViewControllerAnimated:YES completion:^{
			[SVProgressHUD showErrorWithStatus:@"User not found!"];
		}];
	}
	
	// Load user data
	[self.form formRowWithTag:formId].value = [self.user objectForKey:@"uuid"];
	[self.form formRowWithTag:formName].value = [self.user objectForKey:@"name"];
	[self.form formRowWithTag:formEmail].value = [self.user objectForKey:@"email"];
	[self.form formRowWithTag:formPassword].value = [self.user objectForKey:@"password"];
	[self.form formRowWithTag:formShortCode].value = [self.user objectForKey:@"shortCode"];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) validateForm:(UIBarButtonItem *)buttonItem
{
	NSArray * array = [self formValidationErrors];
	
	if([array count] == 0)
	{
		[self storeNewUser];
		
		return;
	}
	
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
		if ([validationStatus.rowDescriptor.tag isEqualToString:formName])
		{
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
			[self animateCell:cell];
		}
		else if ([validationStatus.rowDescriptor.tag isEqualToString:formEmail])
		{
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
			[self animateCell:cell];
		}
		else if ([validationStatus.rowDescriptor.tag isEqualToString:formPassword])
		{
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
			[self animateCell:cell];
		}
	}];
}

- (void) animateCell:(UITableViewCell *)cell
{
	cell.backgroundColor = [UIColor whiteColor];
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		cell.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:0.3f];
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			cell.backgroundColor = [UIColor whiteColor];
		} completion:nil];
	}];
}

- (void) cancelPressed:(UIBarButtonItem * __unused)button
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
