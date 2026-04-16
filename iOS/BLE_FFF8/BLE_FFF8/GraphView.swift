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
            uvViewModel.loadLastHour()
        }
    }
}
