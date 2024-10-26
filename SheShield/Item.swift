//
//  Item.swift
//  SheShield
//
//  Created by sweeya ghanta on 10/26/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
