import Network
import SwiftUI

public enum NetworkStatus {
    case wifi
    case cellular
    case ethernet
    case unknown
    
    public var description: String {
        switch self {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "蜂窝网络"
        case .ethernet:
            return "以太网"
        case .unknown:
            return "未知"
        }
    }
}

@MainActor
public class NetworkMonitor: ObservableObject {
    public static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
    
    @Published public private(set) var isConnected = true
    @Published public private(set) var connectionType = NetworkStatus.wifi
    @Published public private(set) var isExpensive = false
    @Published public private(set) var isConstrained = false
    
    private init() {
        setupMonitor()
    }
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let connectionType = self.checkConnectionType(path)
            Task { @MainActor in
                self.isConnected = path.status == .satisfied
                self.connectionType = connectionType
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
            }
        }
        monitor.start(queue: queue)
    }
    
    nonisolated private func checkConnectionType(_ path: NWPath) -> NetworkStatus {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        monitor.cancel()
    }
    
    public var connectionDescription: String {
        if !isConnected {
            return "未连接"
        }
        return "\(connectionType.description)\(isExpensive ? " (按流量计费)" : "")"
    }
} 