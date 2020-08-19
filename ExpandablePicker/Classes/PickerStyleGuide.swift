//
//  PickerStyleGuide.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/14/20.
//  Copyright © 2020 Kraig Wastlund. All rights reserved.
//

import UIKit

public enum PickerIndentType {
    case none
    case line
    case arrow
    case box
    case custom
}

public struct PickerStyle {
    
    public static var indentType: PickerIndentType = .line
    
    static func indentImageTintColors() -> [UIColor]? {
        if let c = _indentImageTintColors {
            return c
        }
        
        return nil
    }
    
    static func chevronButtonTintColorDark() -> UIColor {
        if let c = _chevronButtonTintColorDark {
            return c
        }
        
        return UIColor.systemBlue
    }
    
    static func chevronButtonTintColorLight() -> UIColor {
        if let c = _chevronButtonTintColorLight {
            return c
        }
        
        return UIColor.systemBlue
    }
    
    public static func set(indentImageTintColors: [UIColor]? = nil, chevronButtonTintColorDark: UIColor? = nil, chevronButtonTintColorLight: UIColor? = nil) {
        _indentImageTintColors = indentImageTintColors
        _chevronButtonTintColorDark = chevronButtonTintColorDark
        _chevronButtonTintColorLight = chevronButtonTintColorLight
    }
    
    private static var _indentImageTintColors: [UIColor]?
    private static var _chevronButtonTintColorDark: UIColor?
    private static var _chevronButtonTintColorLight: UIColor?
}
