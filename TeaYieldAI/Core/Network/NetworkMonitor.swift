import Foundation
import Network

/// Real-time network reachability observer utilizing Apple Network framework.
final class NetworkMonitor: ObservableObject {

    static let shared = NetworkMonitor()

    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var isCellular: Bool = false

    /// Optional closure callback triggered when connection transitions from offline to online.
    var onConnectionRestored: (() -> Void)?

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "teayield.network.monitor", qos: .utility)
    private var wasOffline: Bool = false

    init() {
        self.monitor = NWPathMonitor()
        start()
    }

    deinit {
        monitor.cancel()
    }

    private func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let connected = (path.status == .satisfied)
            let cellular = path.usesInterfaceType(.cellular)

            DispatchQueue.main.async {
                let transitionedToOnline = self.wasOffline && connected
                self.isConnected = connected
                self.isCellular = cellular
                self.wasOffline = !connected

                if transitionedToOnline {
                    self.onConnectionRestored?()
                }
            }
        }
        monitor.start(queue: queue)
    }
}
