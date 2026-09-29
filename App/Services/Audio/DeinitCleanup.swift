/// Runs cleanup work (remove observers) when its owner goes away, without touching actor-isolated
/// state from `deinit` (iOS 18 has no isolated deinit).
final class DeinitCleanup: @unchecked Sendable {
    private var actions: [() -> Void] = []

    func add(_ action: @escaping () -> Void) { actions.append(action) }

    deinit { actions.forEach { $0() } }
}
