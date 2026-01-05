//  Round.swift
//  PointTracker
//  Created by Cameron Alexander Cutler on 1/4/26.
import SwiftData
import SwiftUI
@Model
final class Round {
    var number: Int
    var timestamp: Date
    init(number: Int) {
        self.number = number
        self.timestamp = Date()
    }
}
