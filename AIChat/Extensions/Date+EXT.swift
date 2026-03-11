//
//  Date + EXT.swift
//  AIChat
//
//  Created by macbook on 30.12.2024.
//

import Foundation

extension Date {
    /// Adds the specified number of days, hours, and minutes to the current date.
    /// Negative values subtract time.
    /// - Parameters:
    ///   - days: The number of days to add.
    ///   - hours: The number of hours to add.
    ///   - minutes: The number of minutes to add.
    /// - Returns: A new `Date` with the time adjustments applied.
    func addingTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let totalSeconds = (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60)
        return self.addingTimeInterval(TimeInterval(totalSeconds))
    }
}
