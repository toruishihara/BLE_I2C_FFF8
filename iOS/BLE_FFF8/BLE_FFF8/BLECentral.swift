//
//  BLECentral.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import Foundation
import SwiftUI
import CoreBluetooth
internal import Combine

let SERVICE_UUID = CBUUID(string: "FFF8")
let CHAR_DATA_UUID = CBUUID(string: "FFF9")
let CHAR_CONFIG_UUID = CBUUID(string: "FFFA")

class BLECentral: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var status: String = "Initializing..."
    @Published var lastHex: String = "-"
    @Published var lastAscii: String = "-"
    @Published var uva: UInt16 = 0
    @Published var uvb: UInt16 = 0
    @Published var uvc: UInt16 = 0

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var targetPeripheral: CBPeripheral?
    private var uvNotifyChar: CBCharacteristic?
    private let stream = BLEStream()
    
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
        print("Found:", name)

        guard name == "UV_SENSOR" else { return }

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
extension BLECentral: CBPeripheralDelegate {
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
            peripheral.discoverCharacteristics([CHAR_DATA_UUID], for: s)
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
        for c in chars where c.uuid == CHAR_DATA_UUID {
            uvNotifyChar = c
            status = "Characteristic found."
            peripheral.setNotifyValue(true, for: c)
            return
        }
        status = "Target characteristic not found"
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {

        if let error = error {
            status = "setNotify error: \(error.localizedDescription)"
            return
        }
        status = characteristic.isNotifying ? "Notify ON " : "Notify OFF"
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        if let error = error {
            status = "Notify update error: \(error.localizedDescription)"
            return
        }
        guard let data = characteristic.value else { return }


        // Show HEX
        lastHex = data.map { String(format: "%02X", $0) }.joined(separator: " ")

        uva = UInt16(littleEndian: data.withUnsafeBytes {
            $0.load(fromByteOffset: 2, as: UInt16.self)
        })
        uvb = UInt16(littleEndian: data.withUnsafeBytes {
            $0.load(fromByteOffset: 6, as: UInt16.self)
        })
        uvc = UInt16(littleEndian: data.withUnsafeBytes {
            $0.load(fromByteOffset: 10, as: UInt16.self)
        })

        // For debug
        print("Notify: \(lastHex)")
    }
}

