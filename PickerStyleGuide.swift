//
//  PickerStyleGuide.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/14/20.
//  Copyright © 2020 Kraig Wastlund. All rights reserved.
//

import UIKit

enum PickerStyleType {
    case vanilla
    case custom
    
    func indentImage() -> UIImage {
        guard self == .vanilla else { assert(false, "If non vanilla style has been picked you must specifically set this property."); return UIImage() }
        return #imageLiteral(resourceName: "indent")
    }
    
    func indentImageTintColors() -> [UIColor] {
        guard self == .vanilla else { assert(false, "If non vanilla style has been picked you must specifically set this property."); return [UIColor]() }
        return [.yellow, .blue, .green, .gray, .red, .black, .cyan, .darkGray, .brown]
    }
    
    func chevronTintColor() -> UIColor {
        guard self == .vanilla else { assert(false, "If non vanilla style has been picked you must specifically set this property."); return UIColor() }
        return .systemBlue
    }
}

struct PickerStyle {
    
    static var type: PickerStyleType = .vanilla
    
    static func indentImage() -> UIImage {
        if type == .vanilla {
            return type.indentImage()
        } else {
            guard let i = _indentImage else {
                printIndentImage_ONCE()
                return PickerStyleType.vanilla.indentImage()
            }
            return i
        }
    }
    
    static func indentImageTintColors() -> [UIColor] {
        if type == .vanilla {
            return type.indentImageTintColors()
        } else {
            guard let c = _indentImageTintColors else {
                printIndentImageColors_ONCE()
                return PickerStyleType.vanilla.indentImageTintColors()
            }
            return c
        }
    }
    
    static func chevronButtonTintColorDark() -> UIColor {
        if type == .vanilla {
            return type.chevronTintColor()
        } else {
            guard let c = _chevronButtonTintColorLight else {
                printChevronDark_ONCE()
                return PickerStyleType.vanilla.chevronTintColor()
            }
            return c
        }
    }
    
    static func chevronButtonTintColorLight() -> UIColor {
        if type == .vanilla {
            return type.chevronTintColor()
        } else {
            guard let c = _chevronButtonTintColorLight else {
                printChevronLight_ONCE()
                return PickerStyleType.vanilla.chevronTintColor()
            }
            return c
        }
    }
    
    static func set(indentImage: UIImage? = nil, indentImageTintColors: [UIColor]? = nil, chevronButtonTintColorDark: UIColor? = nil, chevronButtonTintColorLight: UIColor? = nil) {
        _indentImage = indentImage
        _indentImageTintColors = indentImageTintColors
        _chevronButtonTintColorDark = chevronButtonTintColorDark
        _chevronButtonTintColorLight = chevronButtonTintColorLight
    }
    
    private static var _indentImage: UIImage?
    private static var _indentImageTintColors: [UIColor]?
    private static var _chevronButtonTintColorDark: UIColor?
    private static var _chevronButtonTintColorLight: UIColor?
    
    private static var printIndentImage_ONCE: () -> Void = {
        print("POTENTIAL WARNING: Non vanilla type was set for Picker Style but `indentImage` was not specifically set. *ExpandablePicker*")
        return {}
    }()
    
    private static var printIndentImageColors_ONCE: () -> Void = {
        print("POTENTIAL WARNING: Non vanilla type was set for Picker Style but `indentImageTintColors` was not specifically set. *ExpandablePicker*")
        return {}
    }()
    
    private static var printChevronLight_ONCE: () -> Void = {
        print("POTENTIAL WARNING: Non vanilla type was set for Picker Style but `chevronButtonTintColorLight` was not specifically set. *ExpandablePicker*")
        return {}
    }()
    
    private static var printChevronDark_ONCE: () -> Void = {
        print("POTENTIAL WARNING: Non vanilla type was set for Picker Style but `chevronButtonTintColorDark` was not specifically set. *ExpandablePicker*")
        return {}
    }()
}
