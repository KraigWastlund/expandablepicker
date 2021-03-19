//
//  PickerViewController.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/4/20.
//  Copyright © 2020 Fishbowl Inventory. All rights reserved.
//

import UIKit

public protocol PickerProtocol {
    func didSelectPickerData(with code: String, pvc: PickerViewController)
    func scanFailed(with code: String, pvc: PickerViewController)
}

public class PickerViewController: UIViewController, UISearchResultsUpdating {
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    public var datasource = PickerDataSource()
    private var _data: [PickerData]?
    public var delegate: PickerProtocol?
    
    private var _selectedData: PickerData?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    public func set(title:String, subtitle:String?) {
        set(epTitle: title, epSubTitle: subtitle)
    }
    
    private func setup() {
        
        if datasource.usesScanning() {
            navigationItem.rightBarButtonItem = UIBarButtonItem.button(self, action: #selector(barcodePressed), image: UIImage.barcode())
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: [ "table": tableView ]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: [ "table": tableView ]))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: "cell")
        
        conditionData(&datasource.data)
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "search"
        search.definesPresentationContext = true
        search.searchBar.autocapitalizationType = .none
        navigationItem.searchController = search
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if #available(iOS 13, *) {
            // do nothing :)
        } else if self.isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeViewController))
        }
    }
    
    @objc func barcodePressed() {
        #if targetEnvironment(simulator)
        print("SIMULATOR -- NO SCANNING POSSIBLE.")
        return
        #else
        let matchables = Array(datasource.data.compactMap({ $0.scanMatchables }).joined())
        let barcodeScanner = QRCodeBarcodeEntryViewController(matchables: matchables, title: NSLocalizedString("Scan", comment: ""))
        barcodeScanner.delegate = self
        self.present(barcodeScanner, animated: true, completion: nil)
        #endif
    }
    
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    private func checkDuplicates(data: [PickerData]) -> Bool {
        
        for d in data {
            if data.filter({ $0.id == d.id }).count != 1 {
                return true
            }
        }
        
        return false
    }
    
    private func validate(data: [PickerData]) -> Bool {
        
        // check for duplicates
        for d in data {
            if data.filter({ $0.id == d.id }).count != 1 {
                assert(false, "There is a duplicate.")
                return false
            }
        }
        
        // make sure each child has exactly one parent
        for d in data {
            if let parentId = d.parentId, data.filter({ $0.id == parentId }).count != 1 {
                assert(false, "A parent data is missing from the data array.")
                return false
            }
        }
        
        return true
    }
    
    private func conditionData(_ data: inout [PickerData]) {
        // sort and arrange all data into heirarchy and alphabetical
        guard validate(data: data) else { return }
        
        let initialcount = data.count
        
        var tempData = data.sorted(by: { (data1, data2) -> Bool in
            data1.attributedTitle.string > data2.attributedTitle.string // sorted in reverse order for branches and leaves (**insert them in reverse order)
        })
        
        // get root data
        data = tempData.filter({ $0.parentId == nil }).sorted(by: { (data1, data2) -> Bool in
            data1.attributedTitle.string < data2.attributedTitle.string
        })
        
        // make all roots visible
        let _ = data.map({ $0.visible = true })
        
        // remove root data from temp data
        tempData = tempData.filter({ $0.parentId != nil })
        
        // loop until tempData is empty
        while !tempData.isEmpty {
            for d in tempData {
                if let index = data.firstIndex(where: { (childData) -> Bool in childData.id == d.parentId }) {
                    data.insert(d, at: index + 1) // **insert
                    assert(data.filter({ $0.id == d.id }).count == 1)
                    tempData.removeAll { (data) -> Bool in data.id == d.id }
                    assert(tempData.filter({ $0.id == d.id }).count == 0)
                }
            }
        }
        
        for i in 0..<data.count {
            data[i].row = i
            
            var indent = 0
            var indentData = data[i]
            while true {
                if indentData.parentId == nil {
                    break
                } else {
                    indentData = data.filter { $0.id == indentData.parentId }.first!
                    indent += 1
                }
            }
            data[i].indent = indent
        }
        
        assert(initialcount == data.count)
        assert(data.filter({ $0.row == -1 }).count == 0)
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            if let ds = _data {
                datasource.data = ds
                _data = nil
                tableView.beginUpdates()
                tableView.reloadSections([0], with: .fade)
                tableView.endUpdates()
            }
            return
        }
        
        if _data == nil {
            _data = datasource.data.map({ $0.copy() })
        }
        
        // filter by text
        let _ = datasource.data.map({ $0.visible = false; $0.match(matchable: text) }) // mark all as hidden
        let _ = datasource.data.filter({ $0.matchLevel != .none }).map({ $0.visible = true }) // mark those that match search visible
        
        // mark all parents and grandparents visible to children who are visible
        let visibleChildren = datasource.data.filter({ $0.visible == true && $0.parentId != nil })
        for child in visibleChildren {
            var parentId = child.parentId
            while true {
                if parentId == nil { break }
                let _ = datasource.data.filter({ $0.id == parentId }).map({ $0.visible = true })
                let parent = datasource.data.filter({ $0.id == parentId }).first
                parentId = parent?.parentId
            }
        }
        
        tableView.beginUpdates()
        tableView.reloadSections([0], with: .fade)
        tableView.endUpdates()
    }
    
}

extension PickerViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.visibleData().count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PickerTableViewCell else { assert(false, "something bad happened"); return UITableViewCell() }
        
        let data = datasource.visibleData()[indexPath.row]
        let rootData = datasource.rootData(for: data)
        cell.showChevron(datasource.hasChildren(for: data))
        cell.pickerData = data
        cell.delegate = self
        cell.set(indent: data.indent, rootIndented: rootData.indentImageNormal != nil )
        cell.chevronHeading = datasource.data.filter({ $0.visible == true && $0.parentId == data.id }).count == 0 ? .right : .down
        
        // attribute string if searching
        if let c = navigationItem.searchController, let t = c.searchBar.text, !t.isEmpty {
            let attributedSearchString = NSMutableAttributedString(attributedString: data.attributedTitle)
            let numberRanges = data.attributedTitle.string.ranges(of: t, options: .caseInsensitive)
            if numberRanges.isEmpty {
                if data.matchLevel != .none, let range = data.attributedTitle.string.range(of: data.attributedTitle.string) {
                    attributedSearchString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], range: data.attributedTitle.string.nsRange(from: range))
                }
            } else {
                for range in numberRanges {
                    attributedSearchString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], range: data.attributedTitle.string.nsRange(from: range))
                }
            }
            cell.label.attributedText = attributedSearchString
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datasource.visibleData()[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        if let sc = navigationItem.searchController, sc.isActive == true {
            sc.isActive = false
            
            // set search controller delegate and private property (only used on exit when searching)
            sc.delegate = self
            _selectedData = data
        } else {
            delegate?.didSelectPickerData(with: data.id, pvc: self)
        }
    }
}

extension PickerViewController: UISearchControllerDelegate {
    
    public func didDismissSearchController(_ searchController: UISearchController) {
        guard let d = _selectedData else { assert(false, "How did I get here without having `_selectedData`?"); return }
        delegate?.didSelectPickerData(with: d.id, pvc: self)
    }
}

extension PickerViewController: PickerCellSelectionProtocol {
    
    func chevronWasPressed(pickerData: PickerData, isExpanding: Bool) {
        respondToUserClick(on: pickerData, isExpanding: isExpanding)
    }
}

extension PickerViewController {
    
    struct PickerDataComparable: Hashable {
        
        static func == (lhs: PickerDataComparable, rhs: PickerDataComparable) -> Bool {
            return lhs.id == rhs.id && lhs.indexPath == rhs.indexPath
        }
        
        let id: String
        let indexPath: IndexPath
        let title: String
    }
    
    func respondToUserClick(on pickerData: PickerData, isExpanding: Bool) {
        
        let oldData = datasource.data.map({ $0.copy() })
        
        if isExpanding { // if expanding -> mark children visible
            let row = pickerData.row + 1
            for i in row..<datasource.data.count {
                if datasource.data[i].indent > pickerData.indent && datasource.data[i].parentId == pickerData.id {
                    assert(datasource.data[i].visible == false)
                    datasource.data[i].visible = true
                }
                if datasource.data[i].indent == pickerData.indent { break }
            }
        } else { // if collapsing -> mark children and grandchildren hidden
            let row = pickerData.row + 1
            for i in row..<datasource.data.count {
                if datasource.data[i].indent > pickerData.indent {
                    datasource.data[i].visible = false
                } else if datasource.data[i].indent == pickerData.indent { break }
            }
        }
        
        // reload
        var oldComps = oldData.filter({ $0.visible }).enumerated().map({ PickerDataComparable(id: $1.id, indexPath: IndexPath(row: $0, section: 0), title: $1.attributedTitle.string)})
        var newComps = datasource.data.filter({ $0.visible }).enumerated().map({ PickerDataComparable(id: $1.id, indexPath: IndexPath(row: $0, section: 0), title: $1.attributedTitle.string)})
        expandableReload(oldComps: &oldComps, newComps: &newComps)
    }
    
    func expandableReload(oldComps: inout [PickerDataComparable], newComps: inout [PickerDataComparable]) {
        
        var indexPathsToInsert = [IndexPath]()
        var indexPathsToDelete = [IndexPath]()
        
        while !newComps.isEmpty {
            let currentComp = oldComps.first
            let correctComp = newComps.first!
            
            if currentComp?.id == correctComp.id {
                oldComps.removeFirst()
                newComps.removeFirst()
            } else if oldComps.filter({ $0.id == correctComp.id }).count == 1 {
                indexPathsToDelete.append(currentComp!.indexPath)
                let _ = !oldComps.isEmpty ? oldComps.removeFirst() : nil
            } else {
                indexPathsToInsert.append(correctComp.indexPath)
                newComps.removeFirst()
            }
        }
        
        indexPathsToDelete.append(contentsOf: oldComps.map({ $0.indexPath })) // if i have any objects left here, they need to be deleted (collapse bottom cell's children)
        
        if !indexPathsToDelete.isEmpty {
            tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        }
        if !indexPathsToInsert.isEmpty {
            tableView.insertRows(at: indexPathsToInsert, with: .fade)
        }
        assert(indexPathsToDelete.isEmpty || indexPathsToInsert.isEmpty)
    }
}

extension String {
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
              let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)!
        let to = range.upperBound.samePosition(in: utf16)!
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
}

extension UIBarButtonItem {
    
    fileprivate static func button(_ target: Any?, action: Selector, image: UIImage) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        
        if #available(iOS 13, *) {
            button.setImage(image.withTintColor(UIView().traitCollection.userInterfaceStyle == .light ? PickerStyle.barcodeButtonTintColorLight() : PickerStyle.barcodeButtonTintColorDark()), for: .normal)
        } else {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView!.tintColor = UIView().traitCollection.userInterfaceStyle == .light ? PickerStyle.barcodeButtonTintColorLight() : PickerStyle.barcodeButtonTintColorDark()
        }
        
        button.addTarget(target, action: action, for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.imageView?.contentMode = .scaleAspectFit
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        return menuBarItem
    }
}

extension PickerViewController: MatchableAuthenticatedProtocol {
    
    public func codeWasSuccessfullyMatched(vc: UIViewController, code: String) {
        let _ = datasource.data.map({ $0.match(matchable: code) })
        let matches = datasource.data.filter({ $0.matchLevel != .none })
        let singularMatch = matches.filter({ $0.matchLevel == .high }).first
        guard !matches.isEmpty else { return }
        
        vc.dismiss(animated: true) { [weak self] in
            guard let s = self else { return }
            if let sc = s.navigationItem.searchController {
                sc.searchBar.text = code
                sc.isActive = true
                s.updateSearchResults(for: sc)
                if let sm = singularMatch {
                    s.dismiss(animated: true) {
                        s.delegate?.didSelectPickerData(with: sm.id, pvc: s)
                    }
                } else if matches.count == 1 {
                    s.dismiss(animated: true) {
                        s.delegate?.didSelectPickerData(with: matches.first!.id, pvc: s)
                    }
                }
            }
        }
    }
    
    public func codeNotFound(vc: UIViewController, code: String) {
        
        vc.dismiss(animated: true) { [weak self] in
            guard let s = self else { return }
            s.delegate?.scanFailed(with: code, pvc: s)
        }
        
        // do something?
        if let d = delegate {
            d.scanFailed(with: code, pvc: self)
        }
    }
}
