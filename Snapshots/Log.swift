import Cocoa
import FileKit

class Log: NSObject, NSCopying {
    let path: Path
    var parsed: Bool = false

    var valid: Bool {
        return hasSnapshotErrors || hasNewSnapshots
    }

    var hasSnapshotErrors: Bool {
        return snapshotErrors.isEmpty == false
    }

    var hasNewSnapshots: Bool {
        return newSnapshots.isEmpty == false
    }

    var newSnapshots = [ORSnapshotCreationReference]()
    var snapshotErrors = [ORKaleidoscopeCommand]()

    var title: String {
        var message = ""
        if hasSnapshotErrors {
            message += "Recorded new Snapshots"
        }
        if hasNewSnapshots {
            if message.isEmpty == false { message += ", " }
            message += "Got Snapshots Errors"
        }
        return message
    }

    var name: String {
        return path.fileName
    }

    init(path: Path) {
        self.path = path
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let log = Log(path: self.path)
        log.parsed = parsed
        log.newSnapshots = newSnapshots
        log.snapshotErrors = snapshotErrors
        return log
    }

    func updateWithReader(reader: ORLogReader) {
        parsed = true
        snapshotErrors = reader.uniqueDiffCommands()
        newSnapshots = reader.newSnapshots()
    }
}
