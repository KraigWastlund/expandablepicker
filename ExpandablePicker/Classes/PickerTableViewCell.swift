//
//  PickerTableViewCell.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/4/20.
//  Copyright © 2020 Fishbowl Inventory. All rights reserved.
//

import UIKit
import AVKit

protocol PickerCellSelectionProtocol {
    func chevronWasPressed(pickerData: PickerData, isExpanding: Bool)
}

enum PickerCellChevronHeading {
    case right
    case down
}

class PickerTableViewCell: UITableViewCell {
    
    static let imageDim: CGFloat = 40
    static let buttonDim: CGFloat = 44
    static let buttonInset: CGFloat = 10
    static let indentPadding: CGFloat = 24
    
    
    func set(indent: Int, rootIndented: Bool) {
        
        imageWidthConstraint.constant = PickerTableViewCell.imageDim
        imageIndentConstraint.constant = CGFloat(indent) * PickerTableViewCell.indentPadding
        
        if indent > 0 && ((rootIndented == false && pickerData.indentImageNormal != nil) || (PickerStyle.indentType == .arrow)) {
            imageIndentConstraint.constant -= PickerTableViewCell.imageDim
        }
        
        var image: UIImage?
        switch PickerStyle.indentType {
        case .line:
            image = UIImage.indent()
        case .arrow:
            if indent == 0 { break }
            image = UIImage.return()
        case .none:
            break
        case .custom:
            guard let i = pickerData.indentImageNormal else { assert(false, "If `custom` indent type is chosen, picker data must have normal image."); return }
            image = i
        }
        
        if let i = image {
            if let tintColors = PickerStyle.indentImageTintColors() {
                if #available(iOS 13, *) {
                    indentImageView.image = i.withTintColor(tintColors[indent % tintColors.count])
                } else {
                        indentImageView.image = i.withRenderingMode(.alwaysTemplate)
                        indentImageView.tintColor = tintColors[indent % tintColors.count]
                }
            } else {
                indentImageView.image = i
            }
        } else {
            indentImageView.image = nil
            imageWidthConstraint.constant = 0
        }
    }
    
    var pickerData: PickerData! {
        didSet {
            label.attributedText = pickerData.attributedTitle
            sublabel.attributedText = pickerData.attributedSubTitle
            adjustHeight()
        }
    }
    var delegate: PickerCellSelectionProtocol!
    
    var chevronHeading: PickerCellChevronHeading! {
        get {
            return self.chevronButton.transform == CGAffineTransform(rotationAngle: 0.0) ? .right : .down
        }
        set {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let s = self else { return }
                if newValue == .right {
                    s.chevronButton.transform = CGAffineTransform(rotationAngle: 0.0)
                } else {
                    s.chevronButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                }
            }
            
            var closedImage: UIImage?
            var openImage: UIImage?
            if let imageNormal = pickerData.indentImageNormal, let imageExpanded = pickerData.indentImageExpanded {
                closedImage = imageNormal
                openImage = imageExpanded
            }
            
            if let c = closedImage, let o = openImage {
                UIView.animate(withDuration: 0.15, animations: { [weak self] in
                    guard let s = self else { return }
                    s.indentImageView.alpha = 0.0
                }) { [weak self] (complete) in
                    guard let s = self else { return }
                    if let colors = PickerStyle.indentImageTintColors() {
                        if #available(iOS 13, *) {
                            if newValue == .right {
                                s.indentImageView.image = c.withTintColor(colors[s.pickerData.indent % colors.count])
                            } else {
                                s.indentImageView.image = o.withTintColor(colors[s.pickerData.indent % colors.count])
                            }
                        } else {
                            if newValue == .right {
                                s.indentImageView.image = c.withRenderingMode(.alwaysTemplate)
                                s.indentImageView.tintColor = colors[s.pickerData.indent % colors.count]
                            } else {
                                s.indentImageView.image = o.withRenderingMode(.alwaysTemplate)
                                s.indentImageView.tintColor = colors[s.pickerData.indent % colors.count]
                            }
                        }
                    } else {
                        // no tint for images
                        if newValue == .right {
                            s.indentImageView.image = c
                        } else {
                            s.indentImageView.image = o
                        }
                    }
                    
                    UIView.animate(withDuration: 0.15) { [weak self] in
                        guard let s = self else { return }
                        s.indentImageView.alpha = 1.0
                    }
                }
            }
        }
    }
    
    let label = UILabel()
    let sublabel = UILabel()
    private let indentImageView = UIImageView()
    
    private var imageIndentConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!
    private var labelHeightConstraint: NSLayoutConstraint!
    private var subLabelHeightConstraint: NSLayoutConstraint!
    
    private let chevronButton = UIButton(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showChevron(_ showChevron: Bool) {
        chevronButton.isHidden = !showChevron
    }
    
    func isExpanded() -> Bool {
        return chevronButton.transform == CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    
    private func setup() {
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        
        sublabel.translatesAutoresizingMaskIntoConstraints = false
        sublabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        sublabel.textAlignment = .left
        sublabel.adjustsFontSizeToFitWidth = true
        
        indentImageView.translatesAutoresizingMaskIntoConstraints = false
        indentImageView.contentMode = .scaleAspectFit
        indentImageView.clipsToBounds = true
        
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            chevronButton.setImage(UIImage.chevron().withTintColor(traitCollection.userInterfaceStyle == .light ? PickerStyle.chevronButtonTintColorLight() : PickerStyle.chevronButtonTintColorDark()), for: .normal)
        } else {
            chevronButton.setImage(UIImage.chevron().withRenderingMode(.alwaysTemplate), for: .normal)
            chevronButton.imageView!.tintColor = traitCollection.userInterfaceStyle == .light ? PickerStyle.chevronButtonTintColorLight() : PickerStyle.chevronButtonTintColorDark()
        }

        chevronButton.imageView!.contentMode = .scaleAspectFit
        chevronButton.imageView!.clipsToBounds = true
        chevronButton.imageEdgeInsets = UIEdgeInsets(top: PickerTableViewCell.buttonInset, left: PickerTableViewCell.buttonInset, bottom: PickerTableViewCell.buttonInset, right: PickerTableViewCell.buttonInset)
        chevronButton.addTarget(self, action: #selector(chevronPressed), for: .touchUpInside)
        
        contentView.addSubview(label)
        contentView.addSubview(sublabel)
        contentView.addSubview(indentImageView)
        contentView.addSubview(chevronButton)
        
        let views = [ "image": indentImageView, "label": label, "sublabel": sublabel, "button": chevronButton ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[image][label]-[button(\(PickerTableViewCell.buttonDim))]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button(\(PickerTableViewCell.buttonDim))]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-(0@999)-[sublabel]-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        contentView.addConstraint(NSLayoutConstraint(item: indentImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: indentImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        contentView.addConstraint(NSLayoutConstraint(item: sublabel, attribute: .left, relatedBy: .equal, toItem: label, attribute: .left, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: sublabel, attribute: .right, relatedBy: .equal, toItem: label, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        contentView.addConstraint(NSLayoutConstraint(item: chevronButton, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        imageIndentConstraint = NSLayoutConstraint(item: indentImageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .leftMargin, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(imageIndentConstraint)
        
        imageWidthConstraint = NSLayoutConstraint(item: indentImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: PickerTableViewCell.imageDim)
        contentView.addConstraint(imageWidthConstraint)
        
        labelHeightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(labelHeightConstraint)
        
        subLabelHeightConstraint = NSLayoutConstraint(item: sublabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(subLabelHeightConstraint)
    }

    @objc func chevronPressed() {
        
        chevronHeading = chevronHeading == .right ? .down : .right
        delegate.chevronWasPressed(pickerData: pickerData, isExpanding: chevronHeading == .down)
        AudioServicesPlaySystemSound(1519)
    }
    
    private func adjustHeight() {
        guard let attributedTitle = label.attributedText else { return }
        
        var sublabelHeight: CGFloat = 0.0
        if let t = sublabel.attributedText, !t.string.isEmpty {
            var range = NSMakeRange(0, t.string.count)
            let font = t.attribute(.font, at: 0, effectiveRange: &range) as? UIFont ?? UIFont.systemFont(ofSize: 14, weight: .regular)
            sublabelHeight = UILabel.height(text: t.string, font: font, width: sublabel.frame.width)
        }
        subLabelHeightConstraint.constant = sublabelHeight
        
        var range = NSMakeRange(0, attributedTitle.string.count)
        let font = attributedTitle.attribute(.font, at: 0, effectiveRange: &range) as? UIFont ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        labelHeightConstraint.constant = UILabel.height(text: attributedTitle.string, font: font, width: sublabel.frame.width)
    }
}

extension UILabel {
    
    static func height(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
}

extension UIView {

    func fadeIn() {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }


    func fadeOut() {
        UIView.animate(withDuration: 0.13, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }


}
