//
//  BLEStream.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import SwiftUI
import CoreBluetooth

class BLEStream {
    private var continuation: AsyncStream<(Data, CBUUID)>.Continuation?

    lazy var stream: AsyncStream<(Data, CBUUID)> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()

    func yield(_ data: Data, uuid: CBUUID) {
        continuation?.yield((data, uuid))
    }

    func finish() {
        continuation?.finish()
    }
}
