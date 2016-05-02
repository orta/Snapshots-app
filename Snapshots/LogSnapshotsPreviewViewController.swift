import Cocoa
import Quartz
import Interstellar

class LogSnapshotsPreviewViewController: NSViewController {

    @IBOutlet weak var imageBrowser: IKImageBrowserView!
    @IBOutlet weak var titleTextField: NSTextField!

    let newLogSelected = Signal<Log>()
    private var log: Log?

    override func viewDidLoad() {
        super.viewDidLoad()

        newLogSelected.next { log in
            self.log = log
            self.imageBrowser.reloadData()
            self.titleTextField.stringValue = log.title
        }
    }

    override func imageBrowserSelectionDidChange(aBrowser: IKImageBrowserView!) {

    }

    override func imageBrowser(aBrowser: IKImageBrowserView!, itemAtIndex index: Int) -> AnyObject! {
        return ""
    }

    override func numberOfItemsInImageBrowser(aBrowser: IKImageBrowserView!) -> Int {
        guard let log = log else { return 0 }
        return log.snapshotErrors.count + log.newSnapshots.count
    }
}
