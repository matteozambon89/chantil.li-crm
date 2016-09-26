//
//  BLEPrinter.m
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 26/08/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import "BLEPrinter.h"

@implementation BLEPrinter

@synthesize centralManager;
@synthesize connectedPeripheral, connectedService, msgCharacteristic;
@synthesize delegate;
@synthesize txDelayCounter;

// Initialization >>>
- (id) init
{
	self = [super init];

	if(self)
	{
		if(LOG)NSLog(@"[BLEPrinter] Init a central!");

		self.connectedPeripheral = nil;
		self.connectedService = nil;
		self.msgCharacteristic = nil;
		self.txDelayCounter = 0;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
	}

	return self;
}
// <<< Initialization

// Discovery >>>
- (void) startScanning;
{
	if(centralManager.state == CBCentralManagerStatePoweredOn)
	{
		char data[] = QIQU_SERVICE_SHORT_UUID;

		CBUUID *targetUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:data length:sizeof(data)]];

		[centralManager scanForPeripheralsWithServices:@[targetUUID] options:nil];

		if(LOG)NSLog(@"[BLEPrinter] Start Scan");
	}
	else
	{
		if(LOG)NSLog(@"[BLEPrinter] Failed to open the bluetooth");
	}
}

- (void) stopScanning
{
	if(LOG)NSLog(@"[BLEPrinter] Stop Scan");

	[centralManager stopScan];
	
}

- (NSArray<CBPeripheral *> *) retrieveConnectedPeripherals
{
	if(centralManager.state == CBCentralManagerStatePoweredOn)
	{
		char data[] = QIQU_SERVICE_SHORT_UUID;
		
		CBUUID *targetUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:data length:sizeof(data)]];
		
		NSArray<CBPeripheral *> *connectedPeripherals = [centralManager retrieveConnectedPeripheralsWithServices:@[targetUUID]];
		
		if(LOG)NSLog(@"[BLEPrinter] Found %lu connected peripheral", (unsigned long)[connectedPeripherals count]);
		
		return connectedPeripherals;
	}
	else
	{
		if(LOG)NSLog(@"[BLEPrinter] Failed to open the bluetooth");
	}
	
	return @[];
}

- (CBPeripheral *) reconnectPeripheralWithUuid:(NSString *)uuid
{
	if(centralManager.state == CBCentralManagerStatePoweredOn)
	{
		CBUUID *peripheralUuid = [CBUUID UUIDWithString:uuid];
		
		NSArray<CBPeripheral *> *peripherals = [centralManager retrievePeripheralsWithIdentifiers:@[peripheralUuid]];
		
		if([peripherals count] > 0)
		{
			CBPeripheral* peripheral = [peripherals objectAtIndex:0];
			
			if(![self isConnectedWithPeripheral:peripheral])
			{
				[self connectPeripheral:peripheral];
			}
			
			return peripheral;
		}
	}
	else
	{
		if(LOG)NSLog(@"[BLEPrinter] Failed to open the bluetooth");
	}
	
	return nil;
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	if(LOG)NSLog(@"[BLEPrinter] Found a BLE Device : %@", peripheral);
	if(LOG)NSLog(@"[BLEPrinter] advertisementData: %@", advertisementData);
	if(LOG)NSLog(@"[BLEPrinter] RSSI: %@", RSSI);

	// Call Delegate method
	[delegate didFoundPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}
// <<< Discovery

// Connect/Disconnect >>>
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
	if([peripheral state] != CBPeripheralStateConnected)
	{
		[delegate willConnectPeripheral:peripheral];
		
		[centralManager connectPeripheral:peripheral options:nil];

		if(LOG)NSLog(@"[BLEPrinter] connectPeripheral: %@", peripheral);
	}
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
	[centralManager cancelPeripheralConnection:peripheral];

	if(LOG)NSLog(@"[BLEPrinter] disconnectPeripheral: %@", peripheral);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	if(connectedPeripheral != nil)
	{
		connectedPeripheral = nil;
		connectedService = nil;
		msgCharacteristic = nil;
	}

	connectedPeripheral = peripheral;
	[connectedPeripheral setDelegate:self];
	[connectedPeripheral discoverServices:nil];

	// Call Delegate method
	[delegate didConnectPeripheral:connectedPeripheral];

	if(LOG)NSLog(@"[BLEPrinter] didConnectPeripheral: %@", peripheral);
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray *services = [peripheral services];
	NSInteger count = [services count];
	NSInteger i = 0;
	char data[] = QIQU_SERVICE_SHORT_UUID;

	CBUUID *targetUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:data length:sizeof(data)]];

	while(i < count)
	{
		CBUUID *uuid = [(CBService*)[services objectAtIndex:i] UUID];

		if(LOG)NSLog(@"[BLEPrinter] didDiscoverServices: found uuid%@", uuid);

		if([uuid isEqual:targetUUID] == YES)
		{
			connectedService = [services objectAtIndex:i];
			if(LOG)NSLog(@"[BLEPrinter] didDiscoverServices: found 0x18f0");
		}

		i++;
	}

	if(LOG)NSLog(@"[BLEPrinter] didDiscoverServices: %@", services);

	if(connectedService != nil)
	{
		[peripheral discoverCharacteristics:nil forService:connectedService];
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	NSArray *characters = [service characteristics];
	NSInteger count = [characters count];
	NSInteger i = 0;
	char data[] = QIQU_CHARACTERISTIC_TX_UUID;
	CBUUID *targetUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:data length:sizeof(data)]];
	CBCharacteristic *characteristic;

	for(characteristic in characters)
	{
		if(LOG)NSLog(@"[BLEPrinter] didDiscoverCharacteristicsForService: %@", characteristic);
		[peripheral readValueForCharacteristic:characteristic];
		[peripheral setNotifyValue:YES forCharacteristic:characteristic];
	}

	while(i < count)
	{
		CBUUID *uuid = [(CBService*)[characters objectAtIndex:i] UUID];
		if ([uuid isEqual:targetUUID] == YES)
		{
			msgCharacteristic = [characters objectAtIndex:i];

			if(LOG)NSLog(@"[BLEPrinter] didDiscoverCharacteristicsForService: uuid is %@", uuid);
		}
		i++;
	}

}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	if(LOG)NSLog(@"[BLEPrinter] Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);

	// Call Delegate method
	[delegate didFailToConnectPeripheral:peripheral error:error];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	if(connectedPeripheral != nil)
	{
		connectedPeripheral = nil;
	}

	if(LOG)NSLog(@"[BLEPrinter] Disconnect with peripheral: %@", peripheral);

	// Call Delegate method
	[delegate didDisconnectPeripheral:peripheral];

}

- (void) clearDevices
{
	//need disconn ?
	if(connectedPeripheral != nil)
	{
		connectedPeripheral = nil;
	}
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
			if(LOG)NSLog(@"[BLEPrinter] CBCentralManagerStatePoweredOff");

			[self clearDevices];

			break;
		}

		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			if(LOG)NSLog(@"[BLEPrinter] CBCentralManagerStateUnauthorized");

			break;
		}

		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			if(LOG)NSLog(@"[BLEPrinter] CBCentralManagerStateUnknown");

			break;
		}

		case CBCentralManagerStatePoweredOn:
		{
			if(LOG)NSLog(@"[BLEPrinter] CBCentralManagerStatePoweredOn");

			char data[] = QIQU_SERVICE_SHORT_UUID;

			CBUUID *targetUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:data length:sizeof(data)]];

			[centralManager retrieveConnectedPeripheralsWithServices:@[targetUUID]];
			[centralManager scanForPeripheralsWithServices:nil options:nil];

			break;
		}

		case CBCentralManagerStateResetting:
		{
			if(LOG)NSLog(@"[BLEPrinter] CBCentralManagerStateResetting");

			[self clearDevices];

			break;
		}

		case CBCentralManagerStateUnsupported:
		{
			break;
		}
	}

	[delegate didUpdateBluetoothState:[centralManager state]];
}
// <<< Connect/Disconnect

// Sending/Receiving >>>
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if(LOG)NSLog(@"[BLEPrinter] RCV data:%@", [characteristic value]);

	NSData *rcvData = [characteristic value];

	if(rcvData != nil)
	{
		// Call Delegate method
		[delegate didRecieveData:rcvData];
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if(LOG)NSLog(@"[BLEPrinter] didUpdateNotificationStateForCharacteristic:%@:%@", characteristic, error);
}

- (NSData *)stringToGB18030:(NSString *)src
{
	NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
	const char *data = [src cStringUsingEncoding:enc];

	return [NSData dataWithBytes:data length:sizeof(data)];
}

- (void) testData
{
	/*
	[self sendCommandClear];
	[self sendData:[[NSString stringWithFormat:@"hello world\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[self sendCommandLineFeed];


	NSString *barcode = [NSString stringWithFormat:@"%ch%c", GS, 80];
	barcode = [NSString stringWithFormat:@"%@%cw%c", barcode, GS, 1];
	[self sendData:[barcode dataUsingEncoding:NSASCIIStringEncoding]];
	barcode = [NSString stringWithFormat:@"%@%cf%c", barcode, GS, 0];
	[self sendData:[barcode dataUsingEncoding:NSASCIIStringEncoding]];
	barcode = [NSString stringWithFormat:@"%@%cH%c", barcode, GS, 2];
	[self sendData:[barcode dataUsingEncoding:NSASCIIStringEncoding]];
	// barcode = [NSString stringWithFormat:@"%@%ck4%@%c", barcode, GS, @"hello world", NUL];
	// barcode = [NSString stringWithFormat:@"%@%ck%c%@%c", barcode, GS, 4, @"hello world", NUL];
	// barcode = [NSString stringWithFormat:@"%ck%c%c%@", GS, 69, 11, @"hello world"];
	barcode = [NSString stringWithFormat:@"%ck%c%c%@%c", GS, 69, 02, @"hello world", 01];
	[self sendData:[barcode dataUsingEncoding:NSASCIIStringEncoding]];
	[self sendCommandLineFeed];
	*/

	// String Test - passed
//	[self sendCommandClear];
//	[self sendData:[[NSString stringWithFormat:@"hello world\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//	[self sendCommandLineFeed];

	// Barcode Test
	NSString *barcodeTest2 = [NSString stringWithFormat:@"%ch%c%ck%c%c%@%c", GS, 162, GS, 75, (int)[@"hello world" length], @"hello world", LF];
	[self sendCommandClear];
	[self sendData:[@"QRCode test 2 \"GS k char(75) char(11) hello world\"\n" dataUsingEncoding:NSASCIIStringEncoding]];
	[self sendCommandLineFeed];
	[self sendData:[barcodeTest2 dataUsingEncoding:NSASCIIStringEncoding]];
	[self sendCommandLineFeed];


	// [self sendCommandComplete];
}

- (void) sendMessage:(NSString *)message
{
	NSString *unaccentedMessage = [message stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	
	[self sendCommandClear];
	[self sendData:[unaccentedMessage dataUsingEncoding:NSUTF8StringEncoding]];
	[self sendCommandComplete];
}

- (void) sendCommandClear
{
	NSString *clear = [NSString stringWithFormat:@"%c@", ESC];// ESC @
	[self sendData:[clear dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void) sendCommandLineFeed
{
	NSString *lineFeed = [NSString stringWithFormat:@"%c", LF];
	[self sendData:[lineFeed dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void) sendCommandComplete
{
	[self sendCommandLineFeed];
	[self sendCommandLineFeed];
	[self sendCommandLineFeed];
	[self sendCommandLineFeed];
	[self sendCommandLineFeed];
}

- (BOOL) sendData:(NSData*)data
{
	if (data == nil) {
		if(LOG)NSLog(@"[BLEPrinter] Sending Failed! Reason: Data was not available.");
		return NO;
	}

	if(connectedPeripheral == nil){
		if(LOG)NSLog(@"[BLEPrinter] Sending Failed! Reason: Peripheral was not available.");
		return NO;
	}

	if (msgCharacteristic == nil) {
		if(LOG)NSLog(@"[BLEPrinter] Sending Failed! Reason: Characteristic was not available.");
		return NO;
	}

	NSInteger len = [data length];
	NSRange range;
	range.length = 0;
	range.location = 0;
	//int i =  0;

	while(range.location < len)
	{
		if(len - range.location > 20)
		{
			range.length = 20;
		}
		else
		{
			range.length = len - range.location;
		}

		NSData *sendData = [data subdataWithRange:range];

		[connectedPeripheral writeValue:sendData forCharacteristic:msgCharacteristic  type:CBCharacteristicWriteWithoutResponse];

		self.txDelayCounter ++;
		if(self.txDelayCounter >= 3)
		{
			usleep(20000);
			self.txDelayCounter = 0;
		}

		range.location += range.length;
	}

	if(LOG)NSLog(@"[BLEPrinter] SendData:%@", data);

	return YES;

}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	/* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
	//[peripheral readValueForCharacteristic:characteristic];
	if(LOG)NSLog(@"[BLEPrinter] didWriteValueForCharacteristic:%@", [characteristic value]);
	[delegate didSendData:[characteristic value]];
}

// <<< Sending/Receiving

// Utility >>>
- (BOOL) isConnected
{
	return (connectedPeripheral != nil);
}

- (BOOL) isConnectedWithPeripheral:(CBPeripheral*)peripheral
{
	if([self isConnected] == NO)
	{
		return NO;
	}

	return [peripheral isEqual:connectedPeripheral];
}

- (void) enterBackground
{
	if ([[UIDevice currentDevice] isMultitaskingSupported])
	{
		[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
	}
}

- (void) enterForeground
{
	if ([[UIDevice currentDevice] isMultitaskingSupported])
	{
		[[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
	}
}

// <<< Utility

// Line Format >>>

+ (NSString *) lineWithTextToLeft:(NSString *)text
{
	return [NSString stringWithFormat:@"%@\n", text];
}

+ (NSString *) lineWithTextToRight:(NSString *)text
{
	int spaceCharCount = (int)(printerMaxCharPerLine - [text length]);
	
	if(spaceCharCount < 0)
	{
		return [self lineWithTextToLeft:text];
	}
	
	NSString *line = [self lineWithText:text andSpaces:spaceCharCount toRight:YES];
	
	return [NSString stringWithFormat:@"%@\n", line];
}

+ (NSString *) lineWithTextToCenter:(NSString *)text
{
	int spaceCharCount = (int)((printerMaxCharPerLine - [text length])/2);
	
	if(spaceCharCount < 0)
	{
		return [self lineWithTextToLeft:text];
	}
	
	NSString *line = [self lineWithText:text andSpaces:spaceCharCount toRight:YES];
	
	return [NSString stringWithFormat:@"%@\n", line];
}

+ (NSString *) lineWithTextToCenter:(NSString *)text withDivisor:(BOOL)withDivisor
{
	if(withDivisor)
	{
		NSString *line = @"";
		
		NSArray *components = [text componentsSeparatedByString:@"\n"];
		for(NSString *component in components)
		{
			NSString *otherLine = [self lineWithTextToCenter:component];
			
			line = [NSString stringWithFormat:@"%@%@", line, otherLine];
		}
		
		return line;
	}
	else
	{
		return [self lineWithTextToCenter:text];
	}
}

+ (NSString *) lineWithTitle:(NSString *)title andText:(NSString *)text
{
	return [self lineWithTitle:title andText:text toRight:NO];
}

+ (NSString *) lineWithTitle:(NSString *)title andText:(NSString *)text toRight:(BOOL)toRight
{
	int spaceCharCount = (int)(printerMaxCharPerLine - [title length] - [text length]);
	
	if(spaceCharCount < 0)
	{
		return [NSString stringWithFormat:@"%@:\n%@\n", title, text];
	}
	
	if(toRight)
	{
		NSString *spaces = [@"" stringByPaddingToLength:spaceCharCount withString:@" " startingAtIndex:0];
		
		return [NSString stringWithFormat:@"%@:%@%@\n", title, spaces, text];
	}
	else
	{
		return [NSString stringWithFormat:@"%@: %@\n", title, text];
	}
}

+ (NSString *) lineWithColumns:(NSArray *)columns
{
	int maxCharPerColumn = (int)(printerMaxCharPerLine / [columns count]);
	
	NSString *line = @"";
	int count = 0;
	for(NSString *column in columns)
	{
		if(count == [columns count] -1)
		{
			line = [NSString stringWithFormat:@"%@%@\n", line, [self columnWithText:column fittingIn:maxCharPerColumn toRight:YES]];
		}
		else
		{
			line = [NSString stringWithFormat:@"%@%@", line, [self columnWithText:column fittingIn:maxCharPerColumn toRight:NO]];
		}
		count++;
	}
	
	return line;
}

+ (NSString *) columnWithText:(NSString *)text fittingIn:(int)length toRight:(BOOL)toRight
{
	// Count the spaces needed to arrive at the specified length
	int spaceCharCount = (int)(length - [text length]);
	
	// Text is longer than specified length
	if(spaceCharCount < 0)
	{
		// Create an array of lines
		NSMutableArray *lineArr = [[NSMutableArray alloc] initWithArray:@[@""]];
		// Get each component of text
		NSArray *components = [text componentsSeparatedByString:@" "];
		// Start with first line
		int lineIndex = 0;
		// Give each component the possibility to display
		for(NSString *component in components)
		{
			// Get current line
			NSString *line = [lineArr objectAtIndex:lineIndex];
			
			// Check if current line can hold another component and it's space
			int lineLength = (int)([line length] + [component length]);
			
			// Count the separator as well
			if(![line isEqualToString:@""])
			{
				lineLength += 1;
			}
			
			// Current line can hold another component
			if(lineLength < length)
			{
				// If new line -> Current line is component
				if([line isEqualToString:@""])
				{
					line = component;
				}
				// Otherwise space between current line and component
				else
				{
					line = [NSString stringWithFormat:@"%@ %@", line, component];
				}
				
				// Update current line
				[lineArr setObject:line atIndexedSubscript:lineIndex];
			}
			// Exactly the same length (incredible!)
			else if(lineLength == length)
			{
				// If new line -> Current line is component
				if([line isEqualToString:@""])
				{
					line = component;
				}
				// Otherwise space between current line and component
				else
				{
					line = [NSString stringWithFormat:@"%@ %@", line, component];
				}
				// Update current line
				[lineArr setObject:line atIndexedSubscript:lineIndex];
				// Move to a new line
				[lineArr addObject:@""];
				lineIndex += 1;
			}
			// Current line cannot hold another component
			else if(lineLength > length)
			{
				// Add the component to a new line
				// Remove the length and add ... as suffix
				if([component length] > length)
				{
					[lineArr addObject:[NSString stringWithFormat:@"%@...", [component substringWithRange:NSMakeRange(0, length - 3)]]];
				}
				else
				{
					[lineArr addObject:component];
				}
				
				lineIndex += 1;
			}
		}
		
		// Get last line
		int lastLineIndex = (int)[lineArr count] - 1;
		NSString *lasLine = [lineArr objectAtIndex:lastLineIndex];
		
		// Count spaces to reach length
		int spaceCharCountAtLastLine = (int)(length - [lasLine length]);
		
		// Add x spaces to last line
		lasLine = [self lineWithText:lasLine andSpaces:spaceCharCountAtLastLine toRight:toRight];
		
		// Update lst line
		[lineArr setObject:lasLine atIndexedSubscript:lastLineIndex];
		
		// Join all the lines by adding new line character (\n)
		NSString *lines = [lineArr componentsJoinedByString:@"\n"];
		
		return lines;
	}
	
	// Add x spaces to text
	return [self lineWithText:text andSpaces:spaceCharCount toRight:toRight];
}

+ (NSString *) lineWithText:(NSString *)text andSpaces:(int)spaceCharCount toRight:(BOOL)toRight
{
	// Avoid crash by spacesCount being 0 or negative
	if(spaceCharCount <= 0)
	{
		return text;
	}
	
	// Get a string with as many spaces as required
	NSString *spaces = [@"" stringByPaddingToLength:spaceCharCount withString:@" " startingAtIndex:0];
	
	// Spaces are on the left and text is on the right
	if(toRight)
	{
		return [NSString stringWithFormat:@"%@%@", spaces, text];
	}
	
	return [NSString stringWithFormat:@"%@%@", text, spaces];
}

// <<< Line Format

@end
