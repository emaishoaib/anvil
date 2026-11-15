import Foundation

/// A file or folder that belongs to an app, and the folder it was found in.
public struct Leftover: Hashable, Sendable {
    public let url: URL
    public let folder: SearchFolder
}
