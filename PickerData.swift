//
//  PickerData.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/12/20.
//  Copyright © 2020 Kraig Wastlund. All rights reserved.
//

import UIKit

struct PickerDataSource {
    var data = [PickerData]()
    
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
}

class PickerData: Equatable {
    
    func copy(with zone: NSZone? = nil) -> PickerData {
        let copy = PickerData(id: id, title: title, parentId: parentId, indentImageNormal: indentImageNormal, indentImageExpanded: indentImageExpanded)
        copy.indent = indent
        copy.row = row
        copy.visible = visible
        copy.indentImageNormal = indentImageNormal
        copy.indentImageExpanded = indentImageExpanded
        return copy
    }
    
    
    static func == (lhs: PickerData, rhs: PickerData) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let title: String
    let parentId: String?
    var indentImageNormal: UIImage?
    var indentImageExpanded: UIImage?
    var visible: Bool = false
    var row: Int = -1
    var indent: Int = -1
    
    init(id: String, title: String, parentId: String?, indentImageNormal: UIImage? = nil, indentImageExpanded: UIImage? = nil) {
        self.id = id
        self.title = title
        self.parentId = parentId
        self.indentImageNormal = indentImageNormal
        self.indentImageExpanded = indentImageExpanded
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