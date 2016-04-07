import Cocoa
import FileKit
import Interstellar
import Async

class DeveloperDirWatcher: NSObject {
    var fileManager: NSFileManager = NSFileManager.defaultManager()
    var library = Path.UserLibrary
    var derivedDataDir = "Developer/Xcode/DerivedData"

    let appNamesUpdateSignal = Signal<[App]>()
    let appUpdatedSignal = Signal<App>()

    func startParsing() {
        Async.background {
            let apps = self.getAllAppNamesWithTests()
            Async.main { self.appNamesUpdateSignal.update(apps) }

//            for app in apps {
//                self.getLogsForApp(app.name)
//                Async.main { self.appUpdatedSignal.update(app) }
//            }
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
            return App(name: path.parent.parent.fileName)
        }
    }

    func getLogsForApp(name: String) -> [Path] {
        let appLogs = library + derivedDataDir + name + "Logs" + "Test"
        return appLogs.find(searchDepth: 0) { path in
            return path.pathExtension == "xcactivitylog"
        }
    }
}
