import Cocoa
import FileKit
import Interstellar
import Async

class DeveloperDirWatcher: NSObject {
    var fileManager: NSFileManager = NSFileManager.defaultManager()
    var library = Path.UserLibrary
    var derivedDataDir = "Developer/Xcode/DerivedData"

    let appNamesUpdateSignal = Signal<[NSString]>()

    func startParsing() {
        Async.background {
            let names = self.getAllAppNamesWithTests()
            Async.main {
                self.appNamesUpdateSignal.update(names)
            }

        }
    }

    func getAllAppNamesWithTests() -> [String] {
        Path.fileManager = fileManager

        let derived = library + derivedDataDir
        let paths = derived.find(searchDepth: 3) { path in
            return path.rawValue.hasSuffix("/Logs/Test")
        }

        // Looks like:
        // "/Users/orta/Library/Developer/Xcode/DerivedData/Aerodramus-elioeeoyxfebivbqkcrplnueiqkk/Logs/Test"

        return paths.flatMap { path in
            return path.parent.parent.fileName
        }
    }

    func getLogsForApp(name: String) -> [Path] {
        let appLogs = library + derivedDataDir + name + "Tests" + "Logs"
        return appLogs.find(searchDepth: 3) { path in
            return path.pathExtension == "xcactivitylog"
        }

    }

}
