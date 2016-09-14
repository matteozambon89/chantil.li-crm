//
//  SettingsViewController.m
//  Chantil.li CRM
//
//  Created by Matteo on 7/3/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic) BOOL initialized;
@property (strong, nonatomic) XLFormDescriptor *form;
@property (strong, nonatomic) XLFormSectionDescriptor *userSection;

@end

@implementation SettingsViewController

@synthesize form;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if(self)
	{
		[self initializeForm];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if(self)
	{
		[self initializeForm];
	}
	
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self.view setTintColor:[Helper colorPrimary]];
	// Hide the NavigationBar
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	// Hide the ToolBar
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	[self setCurrentValues];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) initializeForm
{
	// Implementation details covered in the next section.
	XLFormSectionDescriptor *section;
	XLFormRowDescriptor *row;

	self.form = [XLFormDescriptor formDescriptorWithTitle:@"Settings"];
	self.form.delegate = self;
	
	// Section - Odoo
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Odoo"];
	[self.form addFormSection:section];
	
	// Odoo - Protocol
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formProtocol rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"http://" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Either http:// or https://" regex:@"^http(s|)\\:\\/\\/$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - Host
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formHost rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"127.0.0.1" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid host like google.com or 127.0.0.1" regex:@"^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9])$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - Port
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formPort rowType:XLFormRowDescriptorTypeInteger];
	[row.cellConfigAtConfigure setObject:@"1234" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid port number" regex:@"^0*(?:6(?:[0-4][0-9]{3}|5(?:[0-4][0-9]{2}|5(?:[0-2][0-9]|3[0-5])))|[1-5][0-9]{4}|[1-9][0-9]{1,3}|[0-9])$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - Login Path
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooLoginPath rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"/login" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid path like /login" regex:@"^((\\/\\w+)*\\/)([\\w\\-\\.]+[^#?\\s]+)(.*)?(#[\\w\\-]+)?$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - Login JS
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooLoginJS rowType:XLFormRowDescriptorTypeTextView];
	[row.cellConfigAtConfigure setObject:@"var hello = \"world\";" forKey:@"textView.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid JS script" regex:@"^.{1,}$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Section - Users
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Users"];
	[self.form addFormSection:section];
	
	// add an empty row to the section.
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"create-user-popup" rowType:XLFormRowDescriptorTypeButton title:@"Add New User"];
	[row.cellConfig setValue:[Helper colorPrimary] forKey:@"textColor"];
	[section addFormRow:row];
	
	self.userSection = section;
	
	// Section - Options
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Options"];
	[self.form addFormSection:section];
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reset-settings" rowType:XLFormRowDescriptorTypeButton title:@"Reset Settings"];
	[row.cellConfig setValue:[UIColor redColor] forKey:@"textColor"];
	row.action.formBlock = ^(XLFormRowDescriptor * sender){
		[Helper resetConfigToDefault];
		
		[self performSegueWithIdentifier:segueSplash sender:self];
	};
	[section addFormRow:row];
}

- (void) setCurrentValues
{
	[self.form formRowWithTag:formProtocol].value = [GVUserDefaults standardUserDefaults].odooProtocol;
	[self.form formRowWithTag:formHost].value = [GVUserDefaults standardUserDefaults].odooHost;
	[self.form formRowWithTag:formPort].value = [GVUserDefaults standardUserDefaults].odooPort;
	[self.form formRowWithTag:formOdooLoginPath].value = [GVUserDefaults standardUserDefaults].odooLoginPath;
	[self.form formRowWithTag:formOdooLoginJS].value = [GVUserDefaults standardUserDefaults].odooLoginJS;
	
	NSArray *usersArr = [GVUserDefaults standardUserDefaults].userList;
	for(NSDictionary *user in usersArr)
	{
		[self addUserRowWithUser:user];
	}
	
	self.initialized = YES;
}

- (void) showCreateUserPopup
{
	CreateUserPopupViewController *popupViewController = [CreateUserPopupViewController new];
	popupViewController.delegate = self;
	
	SharedAppDelegate.popupController = nil;
	SharedAppDelegate.popupController = [[STPopupController alloc] initWithRootViewController:popupViewController];
	if (NSClassFromString(@"UIBlurEffect"))
	{
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		SharedAppDelegate.popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	}
	[SharedAppDelegate.popupController.containerView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController.backgroundView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController presentInViewController:self];
}

- (void) showEditUserPopupForUser:(NSDictionary *)user
{
	EditUserPopupViewController *popupViewController = [EditUserPopupViewController new];
	popupViewController.delegate = self;
	popupViewController.user = user;
	
	SharedAppDelegate.popupController = nil;
	SharedAppDelegate.popupController = [[STPopupController alloc] initWithRootViewController:popupViewController];
	if (NSClassFromString(@"UIBlurEffect"))
	{
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		SharedAppDelegate.popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	}
	[SharedAppDelegate.popupController.containerView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController.backgroundView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController presentInViewController:self];
}

- (void) addUserRowWithUser:(NSDictionary *)user
{
	XLFormRowDescriptor *row;
	
	row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"user:%@", [user valueForKey:@"uuid"]] rowType:XLFormRowDescriptorTypeButton title:[user valueForKey:@"name"]];
	row.value = [user valueForKey:@"uuid"];
	[row.cellConfig setValue:[UIColor blackColor] forKey:@"textColor"];
	
	[self.userSection addFormRow:row];
}

- (void) didSaveUser:(NSDictionary *)user
{
	[self addUserRowWithUser:user];
	
	[self userListCountObserver];
}

- (void) didUpdateUser:(NSDictionary *)user
{
	XLFormRowDescriptor *formRow = [self.form formRowWithTag:[NSString stringWithFormat:@"user:%@", [user valueForKey:@"uuid"]]];
	
	[formRow setTitle:[user valueForKey:@"name"]];
	
	[self userListCountObserver];
}

- (void) didDeleteUser:(NSDictionary *)user
{
	[self.form removeFormRowWithTag:[NSString stringWithFormat:@"user:%@", [user valueForKey:@"uuid"]]];
	
	[self userListCountObserver];
}

- (void) didSelectFormRow:(XLFormRowDescriptor *)formRow
{
	[super didSelectFormRow:formRow];
	
	if([formRow.tag isEqual:@"create-user-popup"])
	{
		[self showCreateUserPopup];
	}
	else if([formRow.tag rangeOfString:@"user:[0-9a-zA-Z\\-]+" options:NSRegularExpressionSearch].location != NSNotFound)
	{
		NSDictionary *user = [Helper userWithUuid:formRow.value];
		[self showEditUserPopupForUser:user];
	}
}

- (void) userListCountObserver
{
	NSArray *userList = [GVUserDefaults standardUserDefaults].userList;
	NSUInteger count = [userList count];

	BOOL isFormValid = (count > 0);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formProtocol] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formHost] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formPort] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooLoginPath] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooLoginJS] doValidation].isValid);
	
	[GVUserDefaults standardUserDefaults].isConfigured = isFormValid;
	
	if(isFormValid)
	{
		// Action Menu visible
		[[KCFABManager defaultInstance] show:YES];
	}
	else
	{
		// Action Menu hidden
		[[KCFABManager defaultInstance] hide:YES];
	}
}

- (void) formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
	// super implementation MUST be called
	[super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];

	if(!self.initialized)
	{
		return;
	}
	
	[self userListCountObserver];
	
	NSArray *array = [self formValidationErrors];
	
	if([array count] == 0)
	{
		newValue = [NSString stringWithFormat:@"%@", newValue];
		
		if(![newValue isEqualToString:(NSString *)oldValue])
		{
			if([formRow.tag isEqualToString:formProtocol])
			{
				[GVUserDefaults standardUserDefaults].odooProtocol = newValue;
			}
			else if([formRow.tag isEqualToString:formHost])
			{
				[GVUserDefaults standardUserDefaults].odooHost = newValue;
			}
			else if([formRow.tag isEqualToString:formPort])
			{
				[GVUserDefaults standardUserDefaults].odooPort = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooLoginPath])
			{
				[GVUserDefaults standardUserDefaults].odooLoginPath = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooLoginJS])
			{
				[GVUserDefaults standardUserDefaults].odooLoginJS = newValue;
			}
			
			UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:formRow]];
			cell.backgroundColor = [UIColor whiteColor];
			
			return;
		}
	}
	
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];

		if([validationStatus.rowDescriptor.tag isEqualToString:formRow.tag])
		{
			if(!validationStatus.isValid)
			{
				UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
				cell.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:0.3f];
			}
		}
	}];
}

@end
