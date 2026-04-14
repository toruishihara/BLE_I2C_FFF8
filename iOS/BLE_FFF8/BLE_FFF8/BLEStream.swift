//
//  BLEStream.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import SwiftUI

class BLEStream {
    private var continuation: AsyncStream<Data>.Continuation?

    lazy var stream: AsyncStream<Data> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()

    func yield(_ data: Data) {
        continuation?.yield(data)
    }

    func finish() {
        continuation?.finish()
    }
}
