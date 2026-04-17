//
//  GraphView.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import SwiftUI
import Charts

struct GraphView: View {
    @ObservedObject var uvViewModel: UVViewModel

    var body: some View {
        VStack {
            Picker("Time Range", selection: $uvViewModel.selectedHours) {
                Text("10min").tag(10.0 / 60.0)
                Text("1h").tag(1.0)
                Text("4h").tag(4.0)
                Text("12h").tag(12.0)
            }
            .pickerStyle(.segmented)
            .padding()

            Text("UVA")
            Chart {
                ForEach(uvViewModel.points) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("UVA", point.uva)
                    )
                    .foregroundStyle(.red)
                    
                }
            }
            Spacer()
            Text("UVB")
            Chart {
                ForEach(uvViewModel.points) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("UVB", point.uvb)
                    )
                    .foregroundStyle(.green)
                }
            }
            Spacer()
            Text("UVC")
            Chart {
                ForEach(uvViewModel.points) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("UVC", point.uvc)
                    )
                    .foregroundStyle(.blue)
                }
            }
        }
        .onAppear {
            uvViewModel.loadData()
        }
    }
}
