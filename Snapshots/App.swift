import Cocoa
import FileKit
import Async

class App: NSObject, NSCopying {
    let name: String
    let lastUpdated: NSDate

    let reader = ORLogReader()
    var logs = [Log]()

    var prettyName: String {
        return name.componentsSeparatedByString("-").first ?? "-"
    }

    init(name: String, date: NSDate) {
        self.name = name
        self.lastUpdated = date
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let app = App(name: self.name, date: self.lastUpdated)
        app.logs = self.logs
        return app
    }

    func readLogs() {
        Async.background {
            for log in self.logs {
                // look into http://blog.krzyzanowskim.com/2015/01/10/nsscanner-for-raw-data-and-files/ ?

                guard let content = try? NSString(contentsOfURL: log.path.URL, encoding: NSUTF16StringEncoding) as String else { continue }

                self.reader.readLog(content)
                log.updateWithReader(self.reader)
                self.reader.erase()
            }
        }

    }
}
