//
//  SelectPrinterPopupViewController.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 14/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "SelectPrinterPopupViewController.h"

@interface SelectPrinterPopupViewController ()

@property (strong, nonatomic) SKSpinner *spinner;
@property (strong, nonatomic) XLFormDescriptor *form;
@property (strong, nonatomic) XLFormSectionDescriptor *scanningPeripheralSection;
@property (strong, nonatomic) XLFormSectionDescriptor *foundPeripheralSection;

@end

@implementation SelectPrinterPopupViewController

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
	// XLFormRowDescriptor *row;

	self.form = [XLFormDescriptor formDescriptorWithTitle:@"Select Printer"];

	// Section - Scanning Devices
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Scannig for devices..."];
	[self.form addFormSection:section];

	self.scanningPeripheralSection = section;

	// Section - Devices
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Devices found:"];
	[self.form addFormSection:section];

	self.foundPeripheralSection = section;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	SharedAppDelegate.peripherals = [[NSMutableDictionary alloc] initWithDictionary:@{}];

	// Setup Spinner
	self.spinner = [[SKSpinner alloc] initWithView:self.view];
	self.spinner.color = [Helper colorPrimary];

	[self.spinner showAnimated:YES];

	// Use predicate to Hide or Show sections based on Spinner
	self.scanningPeripheralSection.hidden = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings){
		return ([SharedAppDelegate.peripherals count] == 0);
	}];
	self.foundPeripheralSection.hidden = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings){
		return ([SharedAppDelegate.peripherals count] > 0);
	}];
}

- (void) viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printerDidFoundPeripheralNotification:) name:@"printer.didFoundPeripheral" object:nil];
	
	// Start scanning for devices
	if(!SharedAppDelegate.printer)
	{
		[Helper setupPeripheralToSearch];
	}
	else
	{
		[SharedAppDelegate.printer startScanning];
	}
	
	if(SharedAppDelegate.bluetoothState != CBManagerStatePoweredOn)
	{
		[SharedAppDelegate.printer stopScanning];
		
		FAKIonIcons *icon = [FAKIonIcons bluetoothIconWithSize:84];
		[icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
		UIImage *iconImage = [icon imageWithSize:CGSizeMake(84, 84)];
		
		[self dismissViewControllerAnimated:NO completion:^{
			[SVProgressHUD showImage:iconImage status:@"Please enable the Bluetooth"];
		}];
	}
	else
	{
		NSArray<CBPeripheral *> *connectedPeripherals = [SharedAppDelegate.printer retrieveConnectedPeripherals];
		for(CBPeripheral *peripheral in connectedPeripherals)
		{
			[self preparePeripheralForAddition:peripheral];
		}
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	if(self.spinner.alpha > 0.0f)
	{
		[self.spinner hideAnimated:NO];
	}

	// Stop scanning for devices
	[SharedAppDelegate.printer stopScanning];

	// Stop observing
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	SharedAppDelegate.peripherals = nil;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) printerDidFoundPeripheralNotification:(NSNotification*)notification
{
	CBPeripheral *peripheral = (CBPeripheral *)[notification.userInfo valueForKey:@"peripheral"];

	[self preparePeripheralForAddition:peripheral];
}

- (void) preparePeripheralForAddition:(CBPeripheral *)peripheral
{
	if(!peripheral.name || !peripheral.identifier)
	{
		return;
	}
	
	NSDictionary *peripheralDict = @{
									 @"name": peripheral.name,
									 @"uuid": [peripheral.identifier UUIDString],
									 @"cbperipheral": peripheral
									 };
	
	if(![SharedAppDelegate.peripherals valueForKey:[peripheralDict valueForKey:@"uuid"]])
	{
		[SharedAppDelegate.peripherals setValue:peripheralDict forKey:[peripheralDict valueForKey:@"uuid"]];
		
		[self addPeripheralRowWithPeripheral:peripheralDict];
	}
}

- (void) addPeripheralRowWithPeripheral:(NSDictionary *)peripheral
{
	XLFormRowDescriptor *row;

	row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"peripheral:%@", [peripheral valueForKey:@"uuid"]] rowType:XLFormRowDescriptorTypeButton title:[peripheral valueForKey:@"name"]];
	row.value = [peripheral valueForKey:@"uuid"];

	NSString *uuid = [peripheral valueForKey:@"uuid"];
	NSDictionary *printer = [Helper printerCurrent];

	[row.cellConfig setValue:[UIColor blackColor] forKey:@"textColor"];

	if(printer)
	{
		NSString *printerUuid = [printer valueForKey:@"uuid"];

		if(printerUuid && [printerUuid isEqualToString:uuid])
		{
			[row.cellConfig setValue:[Helper colorPrimary] forKey:@"textColor"];
		}
	}

	[self.foundPeripheralSection addFormRow:row];

	if(self.spinner.alpha > 0.0f)
	{
		[self.spinner hideAnimated:NO];
	}
}

- (void) didSelectFormRow:(XLFormRowDescriptor *)formRow
{
	[super didSelectFormRow:formRow];
	
	[self deselectFormRow:formRow];

	if([formRow.tag rangeOfString:@"peripheral:[0-9a-zA-Z\\-]+" options:NSRegularExpressionSearch].location != NSNotFound)
	{
		NSDictionary *peripeheralDict = [SharedAppDelegate.peripherals valueForKey:formRow.value];
		CBPeripheral *peripheral = [peripeheralDict valueForKey:@"cbperipheral"];

		if(!peripeheralDict)
		{
			[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Peripheral with %@ doesn't exists", formRow.value]];

			return;
		}

		// Share peripheral
		[Helper printerConnect:peripheral disconnectPrevious:YES];

		// Save peripheral into settings
		[Helper printerSelect:peripeheralDict];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
