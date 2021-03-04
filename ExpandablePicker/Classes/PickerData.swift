//
//  PickerData.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/12/20.
//  Copyright © 2020 Fishbowl Inventory. All rights reserved.
//

import UIKit

public struct PickerDataSource {
    
    public var data = [PickerData]()
    
    func visibleData() -> [PickerData] {
        return data.filter { $0.visible == true }
    }
    
    func hasChildren(for pickerData: PickerData) -> Bool {
        return childrenData(for: pickerData).count > 0
    }
    
    func childrenData(for pickerData: PickerData) -> [PickerData] {
        return data.filter({ $0.parentId == pickerData.id })
    }
    
    func parentData(for pickerData: PickerData) -> PickerData? {
        return data.filter({ $0.id == pickerData.parentId}).first
    }
    
    func rootData(for pickerData: PickerData) -> PickerData {
        var root = pickerData
        
        while true {
            guard let parent = data.filter({ $0.id == root.parentId }).first else { break }
            root = parent
        }
        
        return root
    }
    
    func usesScanning() -> Bool {
        return !data.filter({ $0.scanMatchables != nil }).isEmpty
    }
}

public class PickerData: Equatable {
    
    enum MatchLevel: Int {
        case none = -1
        case low = 0
        case high = 1
    }
    
    func copy(with zone: NSZone? = nil) -> PickerData {
        let copy = PickerData(id: id, title: title, parentId: parentId, indentImageNormal: indentImageNormal, indentImageExpanded: indentImageExpanded)
        copy.indent = indent
        copy.row = row
        copy.visible = visible
        copy.indentImageNormal = indentImageNormal
        copy.indentImageExpanded = indentImageExpanded
        copy.scanMatchables = scanMatchables
        copy.matchLevel = matchLevel
        return copy
    }
    
    
    public static func == (lhs: PickerData, rhs: PickerData) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    let title: String
    let parentId: String?
    var indentImageNormal: UIImage?
    var indentImageExpanded: UIImage?
    var visible: Bool = false
    var row: Int = -1
    var indent: Int = -1
    var scanMatchables: [String]?
    var matchLevel: MatchLevel = .none
    
    func match(matchable: String) {
        
        if let scanMatchables = scanMatchables {
            for m in scanMatchables {
                if m == matchable {
                    matchLevel = .high
                    return
                }
                if m.lowercased().contains(matchable.lowercased()) {
                    matchLevel = .low
                    return
                }
            }
        }
        if title.lowercased().contains(matchable.lowercased()) {
            matchLevel = .low
            return
        }
        
        matchLevel = .none
        return
    }
    
    public init(id: String, title: String, parentId: String?, indentImageNormal: UIImage? = nil, indentImageExpanded: UIImage? = nil, scanMatchables: [String]? = nil) {
        self.id = id
        self.title = title
        self.parentId = parentId
        self.indentImageNormal = indentImageNormal
        self.indentImageExpanded = indentImageExpanded
        self.scanMatchables = scanMatchables
    }
}

extension PickerDataSource {
    
    func pickerData(for id: String) -> PickerData? {
        for data in data {
            if data.id == id {
                return data
            }
        }
        
        assert(false, "Data was not found for id: \(id)")
        
        return nil
    }
}
