import Foundation

public enum ReaderState {
    case initial
    case loading
    case loaded(document: Document)
    case error(String)
}

public protocol StateObserver: AnyObject {
    func stateDidChange(_ state: ReaderState)
}

public class ReaderStateManager {
    public static let shared = ReaderStateManager()
    private var observers = NSHashTable<AnyObject>.weakObjects()
    
    private init() {}
    
    public func addObserver(_ observer: StateObserver) {
        observers.add(observer)
    }
    
    public func removeObserver(_ observer: StateObserver) {
        observers.remove(observer)
    }
    
    // 例如：触发状态改变
    public func updateState(_ newState: ReaderState) {
        for case let observer as StateObserver in observers.allObjects {
            observer.stateDidChange(newState)
        }
    }
} 