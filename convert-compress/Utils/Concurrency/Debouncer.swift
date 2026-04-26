import Foundation

/// Coalesces rapid-fire calls into a single deferred invocation on the main queue.
///
/// A `Debouncer` holds at most one pending work item. Each call to
/// ``schedule(after:_:)`` cancels any previously scheduled block and
/// schedules a new one to run after the given delay.
///
/// ```swift
/// private let debouncer = Debouncer()
/// debouncer.schedule(after: .milliseconds(150)) { [weak self] in
///     self?.refresh()
/// }
/// ```
@MainActor
final class Debouncer {
    private var pending: DispatchWorkItem?

    /// Cancels any previously scheduled block and queues `action` to run after `delay`.
    func schedule(after delay: DispatchTimeInterval, _ action: @escaping @MainActor () -> Void) {
        pending?.cancel()
        let work = DispatchWorkItem { action() }
        pending = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    /// Convenience overload accepting seconds.
    func schedule(after seconds: TimeInterval, _ action: @escaping @MainActor () -> Void) {
        schedule(after: .milliseconds(Int(seconds * 1000)), action)
    }

    /// Cancels any pending block without running it.
    func cancel() {
        pending?.cancel()
        pending = nil
    }
}
