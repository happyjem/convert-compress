import Foundation

struct ProgressState: Equatable {
    var isActive: Bool = false
    var completed: Int = 0
    var total: Int = 0

    var fraction: Double {
        guard isActive, total > 0 else {
            return 0
        }
        return Double(completed) / Double(total)
    }

    var ingestCounterText: String? {
        guard isActive, total > 0 else {
            return nil
        }
        let displayed = min(completed + (completed < total ? 1 : 0), total)
        return "\(displayed)/\(total)"
    }

    mutating func begin(total: Int) {
        self.total = total
        completed = 0
        isActive = total > 0
    }

    mutating func addToTotal(_ count: Int) {
        if !isActive {
            completed = 0
            total = 0
        }
        total += count
        isActive = total > completed
    }

    mutating func increment() {
        completed = min(completed + 1, total)
        if completed >= total {
            isActive = false
        }
    }

    mutating func reset() {
        isActive = false
        completed = 0
        total = 0
    }
}
