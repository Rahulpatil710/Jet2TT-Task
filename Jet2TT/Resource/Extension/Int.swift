//
//  Int.swift
//  Jet2TT
//
//  Created by Rahul Patil on 12/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

extension Int64 {
    
    func formatCounts() -> String {
        let number = Double(self)
        let suffix = ["", "K", "M", "B", "T", "P", "E"]
        var index = 0
        var value = number
        while((value / 1000) >= 1){
            value = value / 1000
            index += 1
        }
        return String(format: "%.1f%@", value, suffix[index]).replacingOccurrences(of: ".0", with: "")
    }
}
