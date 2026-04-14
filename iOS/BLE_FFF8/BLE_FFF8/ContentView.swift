//
//  ContentView.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = BLEViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BLE App for FFF8")
                .font(.title)
            Button("Scan & Connect") {
                print("Tapped Scan & Connect")
                vm.startScan()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
            .foregroundColor(.white)

            Spacer()

            Text("Status: \(vm.status)")
                .font(.headline)

            Group {
                HStack {
                    Text("UVA:")
                    Text("\(vm.uva, specifier: "%d")")
                        .font(.largeTitle)
                }
                HStack {
                    Text("UVB:")
                    Text("\(vm.uvb, specifier: "%d")")
                        .font(.largeTitle)
                }
                HStack {
                    Text("UVC:")
                    Text("\(vm.uvc, specifier: "%d")")
                        .font(.largeTitle)
                }
            }

            VStack(alignment: .leading) {
                Text("Last HEX:")
                    .font(.caption)
                Text(vm.lastHex)
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.top, 8)

            HStack {
                Button("Disconnect") {
                    // You might want to add a disconnect method to BLEViewModel
                    // vm.disconnect()
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview {
    ContentView()
}
