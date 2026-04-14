//
//  ContentView.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var ble = BLECentral()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BLE App for FFF8")
                .font(.title)
            Button("Scan & Connect") {
                print("Tapped")
                ble.startScan()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
            .foregroundColor(.white)

            Spacer()

            Text("Status: \(ble.status)")
                .font(.headline)

            HStack {
                Text("UVA:")
                Text("\(ble.uva, specifier: "%d")")
                    .font(.largeTitle)
            }
            HStack {
                Text("UVB:")
                Text("\(ble.uvb, specifier: "%d")")
                    .font(.largeTitle)
            }
            HStack {
                Text("UVC:")
                Text("\(ble.uvc, specifier: "%d")")
                    .font(.largeTitle)
            }
            HStack {
                //Button("Scan") { ble.startScan() }
                Button("Stop Scan") { ble.stopScan() }
                Button("Disconnect") { ble.disconnect() }
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
