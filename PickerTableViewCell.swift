//
//  PickerTableViewCell.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/4/20.
//  Copyright © 2020 Kraig Wastlund. All rights reserved.
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
    
    static let cellHeight: CGFloat = 44
    static let imageDim: CGFloat = 40
    static let buttonWidth: CGFloat = 80
    static let buttonInset: CGFloat = 26
    static let indentPadding: CGFloat = 24
    
    func set(indent: Int, rootIndented: Bool) {
        
        imageWidthConstraint.constant = PickerTableViewCell.imageDim
        imageIndentConstraint.constant = CGFloat(indent) * PickerTableViewCell.indentPadding
        
        if indent > 0 && rootIndented == false && pickerData.indentImageNormal != nil {
            imageIndentConstraint.constant -= PickerTableViewCell.imageDim
        }
        
        if let image = pickerData.indentImageNormal {
            let colors = PickerStyle.indentImageTintColors()
            indentImageView.image = image.withTintColor(colors[indent % colors.count])
        } else {
            imageWidthConstraint.constant = 0
        }
    }
    
    var pickerData: PickerData! {
        didSet {
            label.attributedText = nil
            label.text = pickerData.title
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
            
            if let imageNormal = pickerData.indentImageNormal, let imageExpanded = pickerData.indentImageExpanded {
                
                UIView.animate(withDuration: 0.15, animations: { [weak self] in
                    guard let s = self else { return }
                    s.indentImageView.alpha = 0.0
                }) { [weak self] (complete) in
                    guard let s = self else { return }
                    let colors = PickerStyle.indentImageTintColors()
                    if newValue == .right {
                        s.indentImageView.image = imageNormal.withTintColor(colors[s.pickerData.indent % colors.count])
                    } else {
                        s.indentImageView.image = imageExpanded.withTintColor(colors[s.pickerData.indent % colors.count])
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
    private let indentImageView = UIImageView()
    private var imageIndentConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!
    
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
        
        indentImageView.translatesAutoresizingMaskIntoConstraints = false
        indentImageView.contentMode = .scaleAspectFit
        indentImageView.clipsToBounds = true
        
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.setImage(#imageLiteral(resourceName: "chevron").withTintColor(traitCollection.userInterfaceStyle == .light ? PickerStyle.chevronButtonTintColorLight() : PickerStyle.chevronButtonTintColorDark()), for: .normal)
        chevronButton.imageView!.contentMode = .scaleAspectFit
        chevronButton.imageView!.clipsToBounds = true
        chevronButton.imageEdgeInsets = UIEdgeInsets(top: PickerTableViewCell.buttonInset, left: PickerTableViewCell.buttonInset, bottom: PickerTableViewCell.buttonInset, right: PickerTableViewCell.buttonInset)
        chevronButton.addTarget(self, action: #selector(chevronPressed), for: .touchUpInside)
        
        contentView.addSubview(label)
        contentView.addSubview(indentImageView)
        contentView.addSubview(chevronButton)
        
        let views = [ "image": indentImageView, "label": label, "button": chevronButton ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[image][label]-[button(\(PickerTableViewCell.buttonWidth))]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[image(\(PickerTableViewCell.imageDim))]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button(\(PickerTableViewCell.buttonWidth))]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint.init(item: indentImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint.init(item: chevronButton, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        imageIndentConstraint = NSLayoutConstraint(item: indentImageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .leftMargin, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(imageIndentConstraint)
        
        imageWidthConstraint = NSLayoutConstraint(item: indentImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(imageWidthConstraint)
    }

    @objc func chevronPressed() {
        
        chevronHeading = chevronHeading == .right ? .down : .right
        delegate.chevronWasPressed(pickerData: pickerData, isExpanding: chevronHeading == .down)
        AudioServicesPlaySystemSound(1519)
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
