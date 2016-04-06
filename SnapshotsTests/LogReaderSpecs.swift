import Quick
import Nimble
import Cocoa

@testable import Snapshots

class LogReaderSpecs: QuickSpec {

    func getLog(named: String) -> String {
        let bundle = NSBundle(forClass: LogReaderSpecs.self)
        let logPath = bundle.pathForResource(named, ofType:".log")!
        return try! NSString(contentsOfFile: logPath, encoding: NSUTF8StringEncoding) as String
    }

    override func spec() {
        it("gives an expected amout of tests") {
            let log = self.getLog("MultipleSnapshotsErrors")
            let reader = ORLogReader()
            reader.readLog(log)

            expect(reader.hasSnapshotTestErrors()) == true
            expect(reader.hasNewSnapshots()) == false

            expect(reader.ksdiffCommands().count) == 8
            expect(reader.uniqueDiffCommands().count) == 8
        }
    }
}