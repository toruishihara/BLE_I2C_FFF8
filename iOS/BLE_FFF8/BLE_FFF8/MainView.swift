//
//  MainView.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//


import SwiftUI

struct MainView: View {
    @StateObject var bleVewModel = BLEViewModel()
    @StateObject var uvViewModel = UVViewModel()

    var body: some View {
        TabView {
            BLEView(vm: bleVewModel)
                .tabItem {
                    Label("BLE", systemImage: "dot.radiowaves.left.and.right")
                }

            GraphView(uvViewModel: uvViewModel)
                .tabItem {
                    Label("Graph", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView(vm: bleVewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var vm: BLEViewModel
    var body: some View {
        Text("Settings Screen")
    }
}
