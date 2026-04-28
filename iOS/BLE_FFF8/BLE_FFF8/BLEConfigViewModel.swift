//
//  BLEConfig.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/18.
//

import Combine
import Foundation

extension Data {
    func toUInt32() -> UInt32? {
        guard count >= 4 else { return nil }
        // Assuming little-endian
        return self.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

enum CommandID: UInt8 {
    case readValue  = 0x11
    case readResult = 0x12
    case writeValue = 0x13
}

enum ConfigID: UInt8 {
    case deviceName        = 0xC0
    case setTimeSec        = 0xC1
    case setTimeUsec       = 0xC2
    case intervalSec       = 0xC3
    case intervalUsec      = 0xC4
    case powerOffTimer     = 0xC5
}

enum ConfigValue {
    case deviceName(String)
    case setTimeSec(UInt32)
    case setTimeUsec(UInt32)
    case intervalSec(UInt32)
    case intervalUsec(UInt32)
    case powerOffTimer(UInt32)
}

@MainActor
class BLEConfigViewModel: ObservableObject {
    private let bleManager: BLEManager
    @Published var deviceName: String = "-" {
        didSet {
            deviceNameDirty = true
        }
    }
    @Published var timeSec: UInt32 = 0
    @Published var timeUSec: UInt32 = 0
    @Published var intervalSec: UInt32 = 1 {
        didSet {
            intervalSecDirty = true
        }
    }
    @Published var intervalUSec: UInt32 = 0
    @Published var powerOffTimer: UInt32 = 1000000
    private var deviceNameDirty = false
    private var intervalSecDirty = false

    private var task: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.bleManager = BLEManager.shared
        bleManager.$receivedConfigBytes
            .handleEvents(receiveOutput: {
                    print("receivedConfigBytes flow triggered: \(String(describing: $0))")
                }
            )
            .compactMap { $0 }
            .compactMap { self.parseConfig($0) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] config in
                switch config {
                case .deviceName(let name):
                    self?.deviceName = name
                case .setTimeSec(let tm):
                    self?.timeSec = tm
                case .setTimeUsec(let tm):
                    self?.timeUSec = tm
                case .intervalSec(let interval):
                    self?.intervalSec = interval
                case .intervalUsec(let interval):
                    self?.intervalUSec = interval
                case .powerOffTimer(let timer):
                    self?.powerOffTimer = timer
                }
            }
            .store(in: &cancellables)
    }
    
    func readDeviceName() async {
        let command = Data([0x11, 0xC0])
        await bleManager.writeConfigCharAsync(data: command)
        
        let data = await bleManager.readConfigCharAsync()
        let bytes = [UInt8](data)
        // Update property (Already on @MainActor)
        self.deviceName = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
        let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("Read Device Name Bytes: \(hex)")
    }
    
    func parseConfig(_ data: Data) -> ConfigValue? {
        let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("parseConfig Bytes: \(hex)")

        guard data.count >= 2 else { return nil }

        guard let configID = ConfigID(rawValue: data[1]) else {
            return nil
        }

        let payload = data.dropFirst(3)

        switch configID {

        case .deviceName:
            return String(data: payload, encoding: .utf8)
                .map { .deviceName($0) }

        case .setTimeSec:
            return payload.toUInt32().map { .setTimeSec($0) }

        case .setTimeUsec:
            return payload.toUInt32().map { .setTimeUsec($0) }

        case .intervalSec:
            return payload.toUInt32().map { .intervalSec($0) }

        case .intervalUsec:
            return payload.toUInt32().map { .intervalUsec($0) }

        case .powerOffTimer:
            return payload.toUInt32().map { .powerOffTimer($0) }
        }
    }
    
    func writeConfigValues() async {
        if (self.deviceNameDirty) {
            var data = Data()
            data.append(CommandID.writeValue.rawValue)
            data.append(ConfigID.deviceName.rawValue)
            let len = UInt8(self.deviceName.utf8.count)
            data.append(len)
            if let utf8Data = self.deviceName.data(using: .utf8) {
                data.append(utf8Data)
            }
            await bleManager.writeConfigCharAsync(data:data)
        }
    }

}
