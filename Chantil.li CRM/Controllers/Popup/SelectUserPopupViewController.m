//
//  SelectUserPopupViewController.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 12/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//


#import "SelectUserPopupViewController.h"

@interface SelectUserPopupViewController ()

@property (strong, nonatomic) XLFormDescriptor *form;
@property (strong, nonatomic) XLFormSectionDescriptor *userSection;

@end

@implementation SelectUserPopupViewController

@synthesize form;
@synthesize delegate;

- (instancetype) init
{
	self = [super init];
	
	if(self)
	{
		self.contentSizeInPopup = CGSizeMake(300, 220);
		self.landscapeContentSizeInPopup = CGSizeMake(400, 220);
		
		[self initializeForm];
	}
	
	return self;
}


- (void) initializeForm
{
	// Implementation details covered in the next section.
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;
	
	self.form = [XLFormDescriptor formDescriptor];
	
	// Section - Email
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Sign In"];
	[self.form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formEmail rowType:XLFormRowDescriptorTypeEmail];
	[row.cellConfigAtConfigure setObject:@"hello@world.net" forKey:@"textField.placeholder"];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Section - Submit
	section = [XLFormSectionDescriptor formSection];
	[self.form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"submit" rowType:XLFormRowDescriptorTypeButton title:@"Login"];
	[row.cellConfig setValue:[Helper colorPrimary] forKey:@"textColor"];
	row.action.formBlock = ^(XLFormRowDescriptor * sender){
		[self deselectFormRow:sender];
		
		[self validateForm];
	};
	[section addFormRow:row];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self.navigationController setNavigationBarHidden:YES];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) validateForm
{
	NSArray *array = [self formValidationErrors];
	
	if([array count] == 0)
	{
		XLFormRowDescriptor *row = [self.form formRowWithTag:formEmail];
		NSDictionary *user = [Helper userWithEmail:row.value];
		
		if(user == nil)
		{
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:row]];
			[self animateCell:cell];
		}
		else
		{
			[self selectUser:user];
		}
		
		return;
	}
	
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		XLFormValidationStatus *validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
		if ([validationStatus.rowDescriptor.tag isEqualToString:formEmail])
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

- (void) selectUser:(NSDictionary *)user
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[delegate didSelectUser:user];
}
@end
