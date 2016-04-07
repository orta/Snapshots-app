import Cocoa
import PXSourceList

class SnapshotsViewController: NSViewController {

    let dev = DeveloperDirWatcher()

    @IBOutlet var appsDataSource: SourceListDataSource!
    @IBOutlet weak var sourceList: PXSourceList!

    override func viewDidLoad() {
        super.viewDidLoad()

        dev.startParsing()

        dev.appNamesUpdateSignal.next { names in
            self.appsDataSource.updateNames(names)
            self.sourceList.reloadData()
        }
    }
    
}


class SourceListController: NSObject, PXSourceListDelegate {

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