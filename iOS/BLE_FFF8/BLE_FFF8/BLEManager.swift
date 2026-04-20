//
//  BLECentral.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import Foundation
import SwiftUI
import CoreBluetooth
import Combine

let SERVICE_UUID = CBUUID(string: "FFF8")
let CHAR_DATA_UUID = CBUUID(string: "FFF9")
let CHAR_CONFIG_UUID = CBUUID(string: "FFFA")

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    static let shared = BLEManager()
    
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var status: String = "Initializing..."
    @Published var receivedConfigBytes: Data?
    public let stream = BLEStream()

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var targetPeripheral: CBPeripheral?
    private var uvNotifyChar: CBCharacteristic?
    private var configChar: CBCharacteristic?
    
    private var readContinuation: CheckedContinuation<Data, Never>?
    private var writeContinuation: CheckedContinuation<Void, Never>?
    private var notifyContinuations: [CBUUID: CheckedContinuation<Data, Error>] = [:]
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        guard central.state == .poweredOn else { return }
        status = "Scanning"
        print("Start scanning")
        central.scanForPeripherals(
            withServices: [SERVICE_UUID],
            options: nil
        )
    }
    
    func stopScan() {
        central.stopScan()
        status = "Stopped"
    }

    func disconnect() {
        guard let peripheral = targetPeripheral else { return }
        central.cancelPeripheralConnection(peripheral)
        targetPeripheral = nil
        status = "Disconnected"
    }

    func writeConfigChar(data: Data) {
        guard let peripheral = targetPeripheral, let char = configChar else {
            print("Write failed: peripheral or characteristic not found")
            return
        }
        print("calling peripheral.writeValue char=\(char.uuid)")
        peripheral.writeValue(data, for: char, type: .withResponse)
    }

    func writeConfigCharAsync(data: Data) async {
        await withCheckedContinuation { continuation in
            self.writeContinuation = continuation
            self.writeConfigChar(data: data)
        }
    }

    func waitNotifyAsync(for characteristic: CBCharacteristic) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            notifyContinuations[characteristic.uuid] = continuation
        }
    }
    
    func readConfigChar() {
        guard let peripheral = targetPeripheral, let char = configChar else {
            print("Read failed: peripheral or characteristic not found")
            return
        }
        print("calling peripheral.readValue char=\(char.uuid)")
        peripheral.readValue(for: char)
    }

    func readConfigCharAsync() async -> Data {
        await withCheckedContinuation { continuation in
            self.readContinuation = continuation
            self.readConfigChar()
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            status = "Bluetooth ON"
            //central.scanForPeripherals(withServices: nil)
        case .poweredOff:
            status = "Bluetooth OFF"
        default:
            status = "State \(central.state.rawValue)"
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? "Unknown"
        print("Found:", name, " id:", peripheral.identifier)

        //guard name == "UV_SENSOR" else { return }

        print("Connecting to", name)

        // Stop scanning once target is found
        central.stopScan()

        targetPeripheral = peripheral
        targetPeripheral!.delegate = self
        central.connect(targetPeripheral!, options: nil)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("Connected to", peripheral.name ?? "Unknown")

        // Discover services AFTER connect
        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print("Failed to connect:", error?.localizedDescription ?? "unknown")
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        print("Disconnected:", error?.localizedDescription ?? "none")
    }

}
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            status = "discoverServices error: \(error.localizedDescription)"
            return
        }
        guard let services = peripheral.services else {
            status = "No services"
            return
        }
        for s in services where s.uuid == SERVICE_UUID {
            status = "Service found"
            peripheral.discoverCharacteristics([CHAR_DATA_UUID, CHAR_CONFIG_UUID], for: s)
            return
        }
        status = "Target service not found"
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        if let error = error {
            status = "discoverCharacteristics error: \(error.localizedDescription)"
            return
        }
        guard let chars = service.characteristics else {
            status = "No characteristics"
            return
        }
        for c in chars {
            if c.uuid == CHAR_DATA_UUID {
                uvNotifyChar = c
                print("Data characteristic found: \(c.uuid)")
                peripheral.setNotifyValue(true, for: c)
            } else if c.uuid == CHAR_CONFIG_UUID {
                configChar = c
                print("Config characteristic found: \(c.uuid)")
                peripheral.setNotifyValue(true, for: c)
            }
        }
        status = "Characteristics found"
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {

        if let error = error {
            status = "setNotify error: \(error.localizedDescription)"
            print(status)
            return
        }
        status = characteristic.isNotifying ? "Notify ON " : "Notify OFF"
        print("didUpdateNotificationStateFor: \(characteristic.uuid)")
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        status = "Value updated"
        print("didUpdateValueFor: \(characteristic.uuid)")
        
        if let error = error {
            notifyContinuations[characteristic.uuid]?.resume(throwing: error)
            notifyContinuations.removeValue(forKey: characteristic.uuid)
            return
        }

        if let data = characteristic.value {
            if characteristic.uuid == CHAR_DATA_UUID {
                stream.yield(data, uuid: characteristic.uuid)
            }
            if characteristic.uuid == CHAR_CONFIG_UUID {
                DispatchQueue.main.async {
                    self.receivedConfigBytes = data
                }
                readContinuation?.resume(returning: data)
                readContinuation = nil
            }
            
            notifyContinuations[characteristic.uuid]?.resume(returning: data)
            notifyContinuations.removeValue(forKey: characteristic.uuid)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CHAR_CONFIG_UUID {
            writeContinuation?.resume(returning: ())
            writeContinuation = nil
        }
    }
}

