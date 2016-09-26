//
//  BLEPrinter.h
//  Chantil.li CRM
//
//  Created by Matteo Zambon on 26/08/16.
//  Copyright © 2016 The Top Hat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#define SERVICE_UUID @"DEADF154-0000-0000-0000-0000DEADF154"

#define QIQU_SERVICE_SHORT_UUID {0x18, 0xf0}
#define QIQU_CHARACTERISTIC_TX_UUID {0x2a, 0xf1}
#define QIQU_CHARACTERISTIC_RX_UUID {0x2a, 0xf0}

#define NUL	0 // Null
#define LF	10 // Line Feed
#define ESC	27 // Escape
#define GS	29 // Group Separator
#define STX 2 // Start Text
#define BEL 7 // Bell
#define DC1 17 // Device Control 1 (oft. XON)


@protocol BLEPrinterDelegate <NSObject>

- (void) didFoundPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void) willConnectPeripheral:(CBPeripheral *)peripheral;
- (void) didConnectPeripheral:(CBPeripheral *)peripheral;
- (void) didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral;
- (void) didRecieveData:(NSData *)data;
- (void) didSendData:(NSData *)data;

- (void) didUpdateBluetoothState:(CBManagerState)state;

@end

@interface BLEPrinter : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, assign) id<BLEPrinterDelegate> delegate;

@property (nonatomic, readwrite)        NSInteger                   txDelayCounter;
@property (nonatomic, retain, strong)   CBCentralManager            *centralManager;
@property (nonatomic, retain, strong)   CBPeripheral                *connectedPeripheral;
@property (nonatomic, retain, strong)   CBMutableCharacteristic     *msgCharacteristic;
@property (nonatomic, retain, strong)   CBService                   *connectedService;
@property (nonatomic, readwrite)        UIBackgroundTaskIdentifier  backgroundRecordingID;

// Discovery
- (void) startScanning;
- (void) stopScanning;
- (NSArray<CBPeripheral *> *) retrieveConnectedPeripherals;
- (CBPeripheral *) reconnectPeripheralWithUuid:(NSString *)uuid;

// Connect/Disconnect
- (void) connectPeripheral:(CBPeripheral *)peripheral;
- (void) disconnectPeripheral:(CBPeripheral *)peripheral;

// Sending/Receiving
- (void) sendMessage:(NSString *)message;
- (BOOL) sendData:(NSData *)data;

// Utility
- (BOOL) isConnected;
- (BOOL) isConnectedWithPeripheral:(CBPeripheral *)peripheral;
- (void) enterBackground;
- (void) enterForeground;

// Line Format
+ (NSString *) lineWithTextToLeft:(NSString *)text;
+ (NSString *) lineWithTextToRight:(NSString *)text;
+ (NSString *) lineWithTextToCenter:(NSString *)text;
+ (NSString *) lineWithTextToCenter:(NSString *)text withDivisor:(BOOL)withDivisor;
+ (NSString *) lineWithTitle:(NSString *)title andText:(NSString *)text;
+ (NSString *) lineWithTitle:(NSString *)title andText:(NSString *)text toRight:(BOOL)toRight;
+ (NSString *) lineWithColumns:(NSArray *)columns;
+ (NSString *) columnWithText:(NSString *)text fittingIn:(int)length toRight:(BOOL)toRight;

@end
