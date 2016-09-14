//
//  SelectPrinterPopupViewController.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 14/09/2016.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "SelectPrinterPopupViewController.h"

@interface SelectPrinterPopupViewController ()

@property (strong, nonatomic) XLFormDescriptor *form;
@property (strong, nonatomic) XLFormSectionDescriptor *section;

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
	XLFormRowDescriptor *row;
	
	self.form = [XLFormDescriptor formDescriptor];
	
	// Section - Email
	section = [XLFormSectionDescriptor formSectionWithTitle:@"Scannig for devices..."];
	[self.form addFormSection:section];
	
	[section addFormRow:row];
	
	self.section = section;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
