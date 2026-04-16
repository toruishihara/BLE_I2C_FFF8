//
//  UVViewModel.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import Foundation
import SwiftUI
internal import Combine

struct UVPoint: Identifiable {
    let id = UUID()
    let time: Date
    let uva: Int
    let uvb: Int
    let uvc: Int
}

@MainActor
class UVViewModel: ObservableObject {
    private let db = UVDatabase()

    @Published var points: [UVPoint] = []

    init() {
        // Initial load of data when the VM is created
        loadLastHour()
    }

    func loadLastHour() {
        let data = db.fetchLastHour()

        points = data.map {
            UVPoint(time: $0.0, uva: Int($0.1), uvb: Int($0.2), uvc: Int($0.3))
        }
    }
}
