import Cocoa
import FileKit
import Interstellar
import Async

class DeveloperDirWatcher: NSObject {
    var fileManager: NSFileManager = NSFileManager.defaultManager()
    var library = Path.UserLibrary
    var derivedDataDir = "Developer/Xcode/DerivedData"

    let appNamesUpdateSignal = Signal<[App]>()
    let appsWithMetadataUpdatedSignal = Signal<[App]>()

    let appUpdatedSignal = Signal<App>()

    func startParsing() {
        Async.background {
            let apps = self.getAllAppNamesWithTests()
            let sorted = apps.sort { $0.lastUpdated.compare($1.lastUpdated) == .OrderedDescending }

            // Optional, note used though
            Async.main { self.appNamesUpdateSignal.update(sorted) }

            for app in apps {
                self.getLogsForApp(app.name).next { app.logs = $0.map { Log(path: $0) } }
            }

            Async.main { self.appsWithMetadataUpdatedSignal.update(sorted) }

        }
    }

    func getAllAppNamesWithTests() -> [App] {
        Path.fileManager = fileManager

        let derived = library + derivedDataDir
        let paths = derived.find(searchDepth: 3) { path in
            return path.rawValue.hasSuffix("/Logs/Test")
        }

        // Looks like:
        // "/Users/orta/Library/Developer/Xcode/DerivedData/Aerodramus-elioeeoyxfebivbqkcrplnueiqkk/Logs/Test"

        return paths.flatMap { path in
            let date = path.modificationDate ?? NSDate.distantPast()
            return App(name: path.parent.parent.fileName, date: date)
        }
    }

    func getLogsForApp(name: String) -> Signal<[Path]> {
        let appLogs = self.library + self.derivedDataDir + name + "Logs" + "Test"
        let queries = ["replace recordSnapshot with a check", "successfully recorded"]
        return Grepper.getPathsMatchingPattern(queries, fromPath: appLogs)
    }
}
