//
//  Date.swift
//  Jet2TT
//
//  Created by Rahul Patil on 12/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

extension Date {
    
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        if secondsAgo < 60 {
            return "\(secondsAgo) seconds"
        } else if secondsAgo < 60 * 60 {
            return "\(secondsAgo / 60) minutes"
        } else if secondsAgo < 60 * 60 * 24 {
            return "\(secondsAgo / 60 / 60) hours"
        } else if secondsAgo < 60 * 60 * 24 * 7{
            return "\(secondsAgo / 60 / 60 / 24 ) days"
        }
        return "\(secondsAgo / 60 / 60 / 24 / 7) weeks"
    }
}
