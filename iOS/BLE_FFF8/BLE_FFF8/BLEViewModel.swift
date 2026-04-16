//
//  BLEViewModel.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

internal import Combine
import Foundation

@MainActor
class BLEViewModel: ObservableObject {
    @Published var uva: UInt16 = 0
    @Published var uvb: UInt16 = 0
    @Published var uvc: UInt16 = 0
    @Published var status: String = "-"
    @Published var lastHex: String = "-"
    @Published var lastAscii: String = "-"

    private let bleManager: BLEManager
    private let db = UVDatabase()
    private var task: Task<Void, Never>?

    init() {
        self.bleManager = BLEManager()
        startListening()
    }

    func startScan() {
        bleManager.startScan()
    }
    
    func startListening() {
        task = Task {
            for await data in bleManager.stream.stream {
                // Convert Data to [UInt8] (Byte Array)
                let bytes = [UInt8](data)
                
                // Now you can work with 'bytes'
                lastHex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
                lastAscii = String(data: data, encoding: .utf8) ?? "-"
                
                if bytes.count >= 12 {
                    // Accessing bytes by index (assuming little-endian)
                    uva = UInt16(bytes[2]) | (UInt16(bytes[3]) << 8)
                    uvb = UInt16(bytes[6]) | (UInt16(bytes[7]) << 8)
                    uvc = UInt16(bytes[10]) | (UInt16(bytes[11]) << 8)
                    
                    // Insert into DB
                    db.insertUVData(uva: uva, uvb: uvb, uvc: uvc)
                    
                    print("\(Date()): \(uva) \(uvb) \(uvc)")
                }
            }
        }
    }

    func stopListening() {
        task?.cancel()
        task = nil
    }
    
    func disconnect() {
        bleManager.disconnect()
        db.printAllRecord()
    }
}
