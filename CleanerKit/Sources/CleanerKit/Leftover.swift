import Foundation

/// A file or folder that belongs to an app, and the folder it was found in. It may be shared when it was only found through an app group the app shares with a program outside it.
public struct Leftover: Hashable, Sendable {
    public let url: URL
    public let folder: SearchFolder
    public let mayBeShared: Bool

    public init(url: URL, folder: SearchFolder, mayBeShared: Bool = false) {
        self.url = url
        self.folder = folder
        self.mayBeShared = mayBeShared
    }
}
