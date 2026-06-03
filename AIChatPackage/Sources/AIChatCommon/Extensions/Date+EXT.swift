import Foundation

extension Date {
    public func addingTimeInterval(
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0
    ) -> Date {
        let totalSeconds = (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60)
        return self.addingTimeInterval(TimeInterval(totalSeconds))
    }
}
