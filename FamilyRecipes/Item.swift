//
//  Item.swift
//  FamilyRecipes
//
//  Created by James Phillips on 11/17/26.
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
