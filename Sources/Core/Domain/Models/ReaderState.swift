import Foundation

public enum ReaderState {
    case initial
    case loading
    case loaded(document: Document)
    case error(String)
}
