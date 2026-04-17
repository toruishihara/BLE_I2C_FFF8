//
//  UVDatabase.swift
//  BLE_FFF8
//
//  Created by Toru Ishihara on 2026/04/14.
//

import SQLite
import Foundation

class UVDatabase {
    private var db: Connection!

    let table = Table("uv_data")

    let id = Expression<Int64>("id")
    let timestamp = Expression<Date>("timestamp")
    let uva = Expression<Int>("uva")
    let uvb = Expression<Int>("uvb")
    let uvc = Expression<Int>("uvc")

    init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try! Connection("\(path)/uv.sqlite3")

        try! db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(timestamp)
            t.column(uva)
            t.column(uvb)
            t.column(uvc)
        })
    }

    func insertUVData(uva uvaValue: UInt16, uvb uvbValue: UInt16, uvc uvcValue: UInt16) {
        let insert = table.insert(
            timestamp <- Date(),
            self.uva <- Int(uvaValue),
            self.uvb <- Int(uvbValue),
            self.uvc <- Int(uvcValue)
        )

        try! db.run(insert)
    }
    
    func fetchLast(hours: Double) -> [(Date, UInt16, UInt16, UInt16)] {
        let startTime = Date().addingTimeInterval(-hours * 3600)

        var result: [(Date, UInt16, UInt16, UInt16)] = []

        do {
            let query = table
                .filter(timestamp >= startTime)
                .order(timestamp.asc)

            for row in try db.prepare(query) {
                result.append((
                    row[timestamp],
                    UInt16(row[uva]),
                    UInt16(row[uvb]),
                    UInt16(row[uvc])
                ))
            }
        } catch {
            print("DB fetch error:", error)
        }

        return result
    }
    
    func printAllRecord() {
        do {
            for row in try db.prepare(table) {
                let time = row[timestamp]
                let uvaVal = row[uva]
                let uvbVal = row[uvb]
                let uvcVal = row[uvc]

                print("Time: \(time), UVA: \(uvaVal), UVB: \(uvbVal), UVC: \(uvcVal)")
            }
        } catch {
            print("Failed to fetch records:", error)
        }
    }

}
