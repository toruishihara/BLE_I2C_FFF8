//
//  UVViewModel.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import Foundation
import SwiftUI
import Combine

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
    private var timer: AnyCancellable?

    @Published var points: [UVPoint] = []
    @Published var selectedHours: Double = 1.0 {
        didSet {
            print("didSet selectedHours=\(selectedHours)")
            loadData()
        }
    }

    init() {
        // Initial load of data when the VM is created
        loadData()
        startTimer()
    }

    func loadData() {
        let data = db.fetchLast(hours: selectedHours)

        points = data.map {
            UVPoint(time: $0.0, uva: Int($0.1), uvb: Int($0.2), uvc: Int($0.3))
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.loadData()
            }
    }
}
