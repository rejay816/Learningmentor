import Foundation

public protocol StateObserver: AnyObject {
    func stateDidChange(_ state: ReaderState)
}
