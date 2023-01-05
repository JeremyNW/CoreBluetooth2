//
//  ContentViewModel.swift
//  CoreBlue2th
//
//  Created by Jeremy Warren on 12/28/22.
//

import Foundation
import CoreBluetooth

class ContentViewModel: NSObject, ObservableObject {
    
    private var centralManager: CBCentralManager?
    private(set) var selectedPeripheral: CBPeripheral?
    @Published var peripherals: [CBPeripheral] = []
    @Published var isConnecting = false
    @Published var isConnected = false
    let sinkCBUUID = CBUUID(string: "0000110A-0000-1000-8000-00805F9B34FB")
    let sourceCBUUID = CBUUID(string: "0x110A")
    let controlCBUUID = CBUUID(string: "0x110C")
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        
    }
    
    func didSelectPeripheral(_ peripheral: CBPeripheral) {
        if !isConnected {
            self.selectedPeripheral = peripheral
            centralManager?.connect(peripheral)
            centralManager?.stopScan()
        } else if isConnected && selectedPeripheral == peripheral {
            selectedPeripheral = nil
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
}

extension ContentViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("Device bluetooth is powered off")
        case .poweredOn:
            print("Central.state (Device Bluetooth) is powered on")
            self.centralManager?.scanForPeripherals(withServices: nil)
        @unknown default:
            print("")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        print("Connected")
        peripheral.discoverServices(nil)
        isConnecting = false
        isConnected = true
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        centralManager?.scanForPeripherals(withServices: [sinkCBUUID])
        print("Disconnected")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Could not connect")
    }
}

extension ContentViewModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
            print(service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print(service)
        // Iterate over the characteristics and print their UUIDs
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
        }
    }
}
