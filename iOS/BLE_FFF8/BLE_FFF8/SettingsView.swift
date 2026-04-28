//
//  SettingsView.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/18.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: BLEConfigViewModel
    var body: some View {
        VStack {
            Text("Settings Screen")
            HStack {
                Text("Device name:")
                TextField("Enter text", text: $vm.deviceName)
            }
            HStack {
                Text("Data send interval(sec):")
                TextField("Enter text", value: $vm.intervalSec, format: .number)
                    .keyboardType(.numberPad)
            }
            Button("Get config") {
                Task {
                    await vm.readDeviceName()
                }
            }
            .padding()
            Button("Write config") {
                Task {
                    await vm.writeConfigValues()
                }
            }
            .padding()
        }
    }
}
