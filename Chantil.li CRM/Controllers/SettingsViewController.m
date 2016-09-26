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
	SharedAppDelegate.lockScreenDelegate = self;

	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self.view setTintColor:[Helper colorPrimary]];
	// Hide the NavigationBar
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	// Hide the ToolBar
	[self.navigationController setToolbarHidden:YES animated:YES];

	[self setCurrentValues];
}

- (void) viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	// Hide the NavigationBar
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	// Hide the ToolBar
	[self.navigationController setToolbarHidden:YES animated:NO];
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
	
	// Odoo - Home Path
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooHomePath rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"/web" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid path like /web" regex:@"^((\\/\\w+)*\\/)([\\w\\-\\.]+[^#?\\s]+)(.*)?(#[\\w\\-]+)?$"]];
	[row setRequired:YES];
	[section addFormRow:row];

	// Odoo - Login Path
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooLoginPath rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"/web/login" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid path like /web/login" regex:@"^((\\/\\w+)*\\/)([\\w\\-\\.]+[^#?\\s]+)(.*)?(#[\\w\\-]+)?$"]];
	[row setRequired:YES];
	[section addFormRow:row];

	// Odoo - Login JS
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooLoginJS rowType:XLFormRowDescriptorTypeTextView];
	[row.cellConfigAtConfigure setObject:@"var hello = \"world\";" forKey:@"textView.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid JS script" regex:@"^.{1,}$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - POS Path
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooPOSPath rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"/pos/web" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid path like /pos/web" regex:@"^((\\/\\w+)*\\/)([\\w\\-\\.]+[^#?\\s]+)(.*)?(#[\\w\\-]+)?$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - POS JS
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooPOSJS rowType:XLFormRowDescriptorTypeTextView];
	[row.cellConfigAtConfigure setObject:@"var hello = \"world\";" forKey:@"textView.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid JS script" regex:@"^.{1,}$"]];
	[row setRequired:YES];
	[section addFormRow:row];
	
	// Odoo - Session - Cookie Name
	row = [XLFormRowDescriptor formRowDescriptorWithTag:formOdooSessionCookieName rowType:XLFormRowDescriptorTypeText];
	[row.cellConfigAtConfigure setObject:@"session_id" forKey:@"textField.placeholder"];
	[row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"Must be a valid name" regex:@"^[a-z_]+$"]];
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

	// Section - Printers
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Printer"];
	[self.form addFormSection:section];

	// Printer - Selected
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"select-printer-popup" rowType:XLFormRowDescriptorTypeButton title:@"Find Printer"];
	[row.cellConfig setValue:[Helper colorPrimary] forKey:@"textColor"];
	[section addFormRow:row];
	// Printer - Info
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"printer-selected" rowType:XLFormRowDescriptorTypeButton title:@"..."];
	[row.cellConfig setValue:[UIColor blackColor] forKey:@"textColor"];
	[section addFormRow:row];
	// Printer - Test
	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"test-printer" rowType:XLFormRowDescriptorTypeButton title:@"Test Printer"];
	[row.cellConfig setValue:[Helper colorPrimary] forKey:@"textColor"];
	row.action.formBlock = ^(XLFormRowDescriptor * sender){
		[self deselectFormRow:sender];
		
		[Helper printerTest];
	};
	[section addFormRow:row];

	// Section - Options
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Options"];
	[self.form addFormSection:section];

	row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reset-settings" rowType:XLFormRowDescriptorTypeButton title:@"Reset Settings"];
	[row.cellConfig setValue:[UIColor redColor] forKey:@"textColor"];
	row.action.formBlock = ^(XLFormRowDescriptor * sender){
		[self deselectFormRow:sender];
		
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
	[self.form formRowWithTag:formOdooHomePath].value = [GVUserDefaults standardUserDefaults].odooHomePath;
	[self.form formRowWithTag:formOdooLoginPath].value = [GVUserDefaults standardUserDefaults].odooLoginPath;
	[self.form formRowWithTag:formOdooLoginJS].value = [GVUserDefaults standardUserDefaults].odooLoginJS;
	[self.form formRowWithTag:formOdooPOSPath].value = [GVUserDefaults standardUserDefaults].odooPOSPath;
	[self.form formRowWithTag:formOdooPOSJS].value = [GVUserDefaults standardUserDefaults].odooPOSJS;
	[self.form formRowWithTag:formOdooSessionCookieName].value = [GVUserDefaults standardUserDefaults].odooSessionCookieName;

	NSArray *usersArr = [GVUserDefaults standardUserDefaults].userList;
	for(NSDictionary *user in usersArr)
	{
		[self addUserRowWithUser:user];
	}
	
	NSDictionary *printer = [Helper printerCurrent];
	if(printer != nil)
	{
		NSString *printerName = [printer valueForKey:@"name"];
		
		XLFormRowDescriptor *formRow = [self.form formRowWithTag:@"printer-selected"];
		
		[formRow setTitle:printerName];
		[self reloadFormRow:formRow];
	}

	[self userListCountObserver];

	self.initialized = YES;
}

- (void) didUnlockUser:(NSDictionary *)user
{
	[self userListCountObserver];
}

- (void) willPromptUnlock
{
}

- (void) lockScreenAtTimeout:(NSTimer *)timer
{
	[Helper lockApp:YES];

	[super checkAppStatus];
}

- (void) showCreateUserPopup
{
	CreateUserPopupViewController *popupViewController = [CreateUserPopupViewController new];
	popupViewController.delegate = self;

	SharedAppDelegate.popupController = nil;
	SharedAppDelegate.popupController = [[STPopupController alloc] initWithRootViewController:popupViewController];
	if (NSClassFromString(@"UIBlurEffect"))
	{
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[Helper blurPrimary]];
		UIVisualEffectView *blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		// UIVisualEffectView *viewInducingVibrancy = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		// [blurredView.contentView addSubview:viewInducingVibrancy];

		SharedAppDelegate.popupController.backgroundView = blurredView;
		[SharedAppDelegate.popupController.backgroundView setOpaque:NO];
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
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[Helper blurPrimary]];
		UIVisualEffectView *blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		// UIVisualEffectView *viewInducingVibrancy = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		// [blurredView.contentView addSubview:viewInducingVibrancy];

		SharedAppDelegate.popupController.backgroundView = blurredView;
		[SharedAppDelegate.popupController.backgroundView setOpaque:NO];
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
	[self reloadFormRow:formRow];

	[self userListCountObserver];
}

- (void) didDeleteUser:(NSDictionary *)user
{
	[self.form removeFormRowWithTag:[NSString stringWithFormat:@"user:%@", [user valueForKey:@"uuid"]]];

	[self userListCountObserver];
}

- (void) showSelectPrinterPopup
{
	SelectPrinterPopupViewController *popupViewController = [SelectPrinterPopupViewController new];
	popupViewController.delegate = self;

	SharedAppDelegate.popupController = nil;
	SharedAppDelegate.popupController = [[STPopupController alloc] initWithRootViewController:popupViewController];
	if (NSClassFromString(@"UIBlurEffect"))
	{
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[Helper blurPrimary]];
		UIVisualEffectView *blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		// UIVisualEffectView *viewInducingVibrancy = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		// [blurredView.contentView addSubview:viewInducingVibrancy];

		SharedAppDelegate.popupController.backgroundView = blurredView;
		[SharedAppDelegate.popupController.backgroundView setOpaque:NO];
	}
	[SharedAppDelegate.popupController.containerView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController.backgroundView setTintColor:[Helper colorPrimary]];
	[SharedAppDelegate.popupController presentInViewController:self];
}

- (void) didSelectPrinter:(NSDictionary *)printer
{
	[[form formRowWithTag:@"select-printer-popup"] setTitle:[printer valueForKey:@"name"]];
}

- (void) didSelectFormRow:(XLFormRowDescriptor *)formRow
{
	[super didSelectFormRow:formRow];
	
	[self deselectFormRow:formRow];

	if([formRow.tag isEqual:@"create-user-popup"])
	{
		[self showCreateUserPopup];
	}
	else if([formRow.tag isEqual:@"select-printer-popup"])
	{
		[self showSelectPrinterPopup];
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
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooHomePath] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooLoginPath] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooLoginJS] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooPOSPath] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooPOSJS] doValidation].isValid);
	isFormValid = (isFormValid && [[self.form formRowWithTag:formOdooSessionCookieName] doValidation].isValid);

	[GVUserDefaults standardUserDefaults].isConfigured = isFormValid;

	if(isFormValid)
	{
		// Action Menu visible
		[Helper menuShow];
	}
	else
	{
		// Action Menu hidden
		[Helper menuHide];
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

		if([oldValue isEqual:[NSNull null]] || ![newValue isEqualToString:(NSString *)oldValue])
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
			else if([formRow.tag isEqualToString:formOdooHomePath])
			{
				[GVUserDefaults standardUserDefaults].odooHomePath = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooLoginPath])
			{
				[GVUserDefaults standardUserDefaults].odooLoginPath = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooLoginJS])
			{
				[GVUserDefaults standardUserDefaults].odooLoginJS = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooPOSPath])
			{
				[GVUserDefaults standardUserDefaults].odooPOSPath = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooPOSJS])
			{
				[GVUserDefaults standardUserDefaults].odooPOSJS = newValue;
			}
			else if([formRow.tag isEqualToString:formOdooSessionCookieName])
			{
				[GVUserDefaults standardUserDefaults].odooSessionCookieName = newValue;
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
