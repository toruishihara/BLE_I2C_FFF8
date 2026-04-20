//
//  MainView.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//


import SwiftUI

struct MainView: View {
    @StateObject var bleViewModel = BLEViewModel()
    @StateObject var uvViewModel = UVViewModel()
    @StateObject var bleConfigViewModel = BLEConfigViewModel()

    var body: some View {
        TabView {
            BLEView(vm: bleViewModel)
                .tabItem {
                    Label("BLE", systemImage: "dot.radiowaves.left.and.right")
                }

            GraphView(uvViewModel: uvViewModel)
                .tabItem {
                    Label("Graph", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView(vm: bleConfigViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

