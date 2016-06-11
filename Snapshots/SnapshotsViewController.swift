import Cocoa
import PXSourceList
import Interstellar
import FileKit

class SnapshotsViewController: NSViewController {

    let dev = DeveloperDirWatcher()

    @IBOutlet var sourceListDelegate: SourceListController!
    @IBOutlet var appsDataSource: SourceListDataSource!
    @IBOutlet var logsDataSource: SnapshotLogDataSource!

    @IBOutlet weak var sourceList: PXSourceList!

    override func viewDidLoad() {
        super.viewDidLoad()

        dev.startParsing()

        dev.appsWithMetadataUpdatedSignal.next { names in
            self.appsDataSource.updateNames(names)
            self.sourceList.reloadData()
        }

        sourceListDelegate.appSelected.next { app in
            self.dev.getLogsForApp(app.name).next { paths in
                app.logs = paths.map { Log(path: $0) }

                self.logsDataSource.logsForSelectedApp = app.logs
                app.readLogs()
            }
        }

        logsDataSource.logSelected.next { log in
            let s = self.snapshotsPreviewController
            s.newLogSelected.update(log)
        }
    }

    @IBAction func reloadAppsForSnapshots(sender: AnyObject) {
        dev.startParsing()
    }

    var splitController: NSSplitViewController {
        return childViewControllers.filter { $0.isKindOfClass(NSSplitViewController) }.first! as! NSSplitViewController
    }


    var snapshotsPreviewController: LogSnapshotsPreviewViewController {
        return splitController.childViewControllers.filter { $0.isKindOfClass(LogSnapshotsPreviewViewController) }.first! as! LogSnapshotsPreviewViewController
    }
}

class SnapshotLogController: NSObject {
    let reader = ORLogReader()
}

class SnapshotLogDataSource: NSObject {
    dynamic var logsForSelectedApp = [Log]()

    let logSelected = Signal<Log>()

    @IBOutlet weak var logsTableView: NSTableView!

    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(selectionChanged), name: NSTableViewSelectionDidChangeNotification, object: logsTableView)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func selectionChanged(notification: NSNotification) {
        guard let table = notification.object as? NSTableView else { return }
        if table.selectedRow >= 0 {
            logSelected.update(logsForSelectedApp[table.selectedRow])
        }
    }
}

class SourceListController: NSObject, PXSourceListDelegate {

    let appSelected = Signal<App>()

    func sourceList(aSourceList: PXSourceList!, isGroupAlwaysExpanded group: AnyObject!) -> Bool {
        return true
    }

    func sourceList(sourceList: PXSourceList!, viewForItem item: AnyObject!) -> NSView! {
        guard let item = item as? PXSourceListItem else { return NSView() }

        let identifier = sourceList.levelForItem(item) == 0 ? "HeaderCell" : "MainCell"
        guard let cellView = sourceList.makeViewWithIdentifier(identifier, owner: nil) as? PXSourceListTableCellView else { return NSView() }

        guard let app = item.representedObject as? App else {
            // Must be a header
            cellView.textField?.stringValue = item.title
            return cellView
        }

        cellView.textField?.stringValue = app.prettyName
        return cellView;
    }

    func sourceListSelectionDidChange(notification: NSNotification!) {
        let sourceList = notification.object as! PXSourceList
        guard let newSelectedItem = sourceList.itemAtRow(sourceList.selectedRow) as? PXSourceListItem else { return }
        guard let app = newSelectedItem.representedObject as? App else { return }

        appSelected.update(app)
    }
}

class SourceListDataSource: NSObject, PXSourceListDataSource {

    var snapshots = PXSourceListItem(title: "Snapshots", identifier: "root")

    var sourceListItems = [PXSourceListItem]()

    var rootNodes: [PXSourceListItem] {
        return [snapshots]
    }

    func updateNames(apps: [App]) {
        snapshots.removeChildItems(snapshots.children)
        let useful:[PXSourceListItem] = apps.filter { $0.logs.isEmpty == false }.map {
            return PXSourceListItem(representedObject: $0, icon:nil)
        }
        snapshots.children = useful
    }

    func sourceList(aSourceList: PXSourceList!, child index: UInt, ofItem item: AnyObject!) -> AnyObject! {
        if item == nil { return rootNodes[Int(index)] }
        guard let item = item as? PXSourceListItem else { return nil }
        return item.children[Int(index)]
    }

    func sourceList(sourceList: PXSourceList!, numberOfChildrenOfItem item: AnyObject!) -> UInt {
        if item == nil { return UInt(rootNodes.count) }
        guard let item = item as? PXSourceListItem else { return 0 }
        return UInt(item.children.count)
    }

    func sourceList(aSourceList: PXSourceList!, isItemExpandable item: AnyObject!) -> Bool {
        guard let item = item as? PXSourceListItem else { return false }
        return item.hasChildren()
    }

    func sourceList(aSourceList: PXSourceList!, objectValueForItem item: AnyObject!) -> AnyObject! {
        return NSObject()
    }
}



