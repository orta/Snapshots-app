import Cocoa
import PXSourceList
import Interstellar
import FileKit

class SnapshotsViewController: NSViewController {

    let reader = ORLogReader()
    let dev = DeveloperDirWatcher()

    @IBOutlet var sourceListDelegate: SourceListController!
    @IBOutlet var appsDataSource: SourceListDataSource!
    @IBOutlet var logsDataSource: SnapshotLogDataSource!

    @IBOutlet weak var sourceList: PXSourceList!

    override func viewDidLoad() {
        super.viewDidLoad()

        dev.startParsing()

        dev.appNamesUpdateSignal.next { names in
            self.appsDataSource.updateNames(names)
            self.sourceList.reloadData()
        }

        sourceListDelegate.appSelected.next { app in
            self.dev.getLogsForApp(app.name) { paths in
                self.logsDataSource.pathsForSelectedApp = paths.map { $0.rawValue }
            }
        }

        logsDataSource.logSelected.next { path in
            
        }
    }
}

class SnapshotLogDataSource: NSObject {
    dynamic var pathsForSelectedApp = [NSString]()

    let logSelected = Signal<String>()

    @IBOutlet weak var logsTableView: NSTableView!

    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(selectionChanged), name: NSTableViewSelectionDidChangeNotification, object: logsTableView)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func selectionChanged(notification: NSNotificationCenter) {
        logSelected.update("")
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
        let children:[PXSourceListItem] = apps.map {
            return PXSourceListItem(representedObject: $0, icon:nil)
        }
        snapshots.children = children
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



