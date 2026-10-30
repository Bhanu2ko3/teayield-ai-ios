import Foundation
@testable import TeaYieldAI

/// Test double implementing NetworkMonitorProtocol to simulate connectivity states.
final class MockNetworkMonitor: NetworkMonitorProtocol {

    var isConnected: Bool = true
    var isCellular: Bool = false
    var onConnectionRestored: (() -> Void)?

    init(isConnected: Bool = true, isCellular: Bool = false) {
        self.isConnected = isConnected
        self.isCellular = isCellular
    }

    func simulateTransitionToOnline() {
        isConnected = true
        onConnectionRestored?()
    }

    func simulateTransitionToOffline() {
        isConnected = false
    }
}
