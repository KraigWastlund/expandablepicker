//
//  PickerStyleGuide.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/14/20.
//  Copyright © 2020 Fishbowl Inventory. All rights reserved.
//

import UIKit
import AVFoundation

public enum PickerIndentType {
    case none
    case line
    case arrow
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
    
    static func barcodeButtonTintColorDark() -> UIColor {
        if let c = _chevronButtonTintColorDark {
            return c
        }
        
        return UIColor.systemBlue
    }
    
    static func barcodeButtonTintColorLight() -> UIColor {
        if let c = _chevronButtonTintColorLight {
            return c
        }
        
        return UIColor.systemBlue
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
    
    static func scannerCameraFacingPosition() -> AVCaptureDevice.Position {
        if let c = _scannerCameraFacingPosition {
            return c
        }
        return .back
    }
    
    public static func set(indentImageTintColors: [UIColor]? = nil, chevronButtonTintColorDark: UIColor? = nil, chevronButtonTintColorLight: UIColor? = nil, barcodeButtonTintColorDark: UIColor? = nil, barcodeButtonTintColorLight: UIColor? = nil, scannerCameraFacingPosition: AVCaptureDevice.Position? = nil) {
        _indentImageTintColors = indentImageTintColors
        _chevronButtonTintColorDark = chevronButtonTintColorDark
        _chevronButtonTintColorLight = chevronButtonTintColorLight
        _barcodeButtonTintColorLight = barcodeButtonTintColorLight
        _barcodeButtonTintColorDark = barcodeButtonTintColorDark
        _scannerCameraFacingPosition = scannerCameraFacingPosition
    }
    
    private static var _indentImageTintColors: [UIColor]?
    private static var _barcodeButtonTintColorDark: UIColor?
    private static var _barcodeButtonTintColorLight: UIColor?
    private static var _chevronButtonTintColorDark: UIColor?
    private static var _chevronButtonTintColorLight: UIColor?
    private static var _scannerCameraFacingPosition: AVCaptureDevice.Position?
}
