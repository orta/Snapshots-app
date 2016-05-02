import Cocoa
import Interstellar
import FileKit
import Async

class Grepper: NSObject {

    class func getPathsMatchingPattern(patterns:[String], fromPath: Path) -> Signal<[Path]> {
        let signal = Signal<[Path]>()

        Async.background {
            let task:NSTask = NSTask()
            let pipe:NSPipe = NSPipe()

            task.launchPath = "/usr/bin/grep"
            var arguments = ["-lr"]
            for pattern in patterns { arguments.append("-e"); arguments.append(pattern) }
            arguments.append(fromPath.rawValue)

            task.arguments = arguments
            task.standardOutput = pipe
            task.launch()

            let handle = pipe.fileHandleForReading
            let data = handle.readDataToEndOfFile()

            guard let pathString = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                Async.main { signal.update([]) }
                return
            }

            let pathStrings = pathString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())

            Async.main { signal.update(pathStrings.map { Path($0) }) }
        }

        return signal
    }

}
