import Cocoa
import FileKit

class App: NSObject, NSCopying {
    let name: String
    var logs = [Path]()

    var prettyName: String {
        return name.componentsSeparatedByString("-").first ?? "-"
    }

    init(name: String) {
        self.name = name
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let app = App(name: self.name)
        app.logs = self.logs
        return app
    }
}
