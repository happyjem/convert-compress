import Foundation

enum ConcurrentMap {
    static func compactMap<Input, Output>(
        _ inputs: [Input],
        maxConcurrent: Int,
        priority: TaskPriority = .utility,
        operation: @escaping (Input) async -> Output?
    ) async -> [Output] {
        guard !inputs.isEmpty else {
            return []
        }

        let semaphore = AsyncSemaphore(value: max(1, maxConcurrent))
        return await withTaskGroup(of: Output?.self) { group in
            for input in inputs {
                group.addTask(priority: priority) {
                    guard !Task.isCancelled else { return nil }
                    await semaphore.acquire()
                    let result = await operation(input)
                    await semaphore.release()
                    return result
                }
            }

            var results: [Output] = []
            for await result in group {
                if let result {
                    results.append(result)
                }
            }
            return results
        }
    }
}
