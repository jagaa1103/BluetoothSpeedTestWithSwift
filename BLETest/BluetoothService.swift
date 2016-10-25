//
//  BluetoothService.swift
//  BLETest
//
//  Created by Enkhjargal Gansukh on 10/14/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    static let instance = BluetoothService()
    
    var ready: Array<UInt8> = [0xF7, 0x03, 0x02, 0x01, 0x01]
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var service: CBService!
    var sendCharacteristic: CBCharacteristic!
    var receiveCharacteristic: CBCharacteristic!
    var bluetoothAvailable = false
    
    var golfinPeripheral: CBPeripheral? = nil
    
    var viewCtrl: ViewController? = nil
    var myTimer: Timer? = nil
    var times = [Int64]()
    
    
    override init() {
        super.init()
    }
    
    func startService(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setView(view: ViewController) {
        self.viewCtrl = view
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state)
        {
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            bluetoothAvailable = true;
            
        case .resetting:
            print("CoreBluetooth BLE hardware is resetting")
            
        case .unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            
        case .unknown:
            print("CoreBluetooth BLE state is unknown");
            
        case .unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            
        }
    }
    
    func discoverDevices(){
        if bluetoothAvailable == true {
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "GOLFIN"){
            self.peripheral = peripheral
            self.centralManager.connect( self.peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect with : \(peripheral.name!)")
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral : GOLFIN")
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(":::::::::::::::::::::: didDiscoverServices ::::::::::::::::::::::")
        if peripheral.identifier != self.peripheral.identifier || peripheral.services == nil || peripheral.services?.count == 0 {
            return
        }
        for service in peripheral.services! {
            print(service)
            self.service = service
        }
        if self.service != nil {
            self.peripheral.discoverCharacteristics(nil, for: self.service!)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("didWriteValueFor")
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor")
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for character in self.service.characteristics! {
            if "\(character.uuid)" == "0783B03E-8535-B5A0-7140-A304D2495CB8" {
                self.receiveCharacteristic = self.service.characteristics?[0]
                self.peripheral.setNotifyValue(true, for: self.receiveCharacteristic)
            }else if "\(character.uuid)" == "0783B03E-8535-B5A0-7140-A304D2495CBA" {
                self.sendCharacteristic = self.service.characteristics?[1]
            }
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("didUpdateValueFor")
    }
    
    func sendReady(){
        let data2 = NSData(bytes: ready, length: ready.count)
        print(self.service.uuid)
        print(self.sendCharacteristic.uuid)
        print(data2)
        self.peripheral.writeValue(data2 as Data, for: self.sendCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        self.myTimer = nil
        self.times = [Int64]()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        printTime()
    }
    
    
    
    func printTime(){
        myTimer?.invalidate()
        let nowDouble = NSDate().timeIntervalSince1970
        times.append(Int64(nowDouble*1000))
        myTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {_ in 
            let elapsedTime = (self.times[2]) - (self.times[self.times.count - 1])
            self.viewCtrl?.elapsedTimeLabel.text = "\(elapsedTime)"
        })
    }
}
