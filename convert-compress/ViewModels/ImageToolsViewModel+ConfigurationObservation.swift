import Combine
import Foundation

extension ImageToolsViewModel {
    func observeConfigurationChanges(_ action: @escaping () -> Void) {
        var lastConfiguration = currentConfiguration
        objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let configuration = self.currentConfiguration
                guard configuration != lastConfiguration else { return }
                lastConfiguration = configuration
                action()
            }
            .store(in: &cancellables)
    }
}
