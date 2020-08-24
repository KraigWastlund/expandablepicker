//
//  Extensions.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/17/20.
//  Copyright © 2020 Fishbowl Inventory. All rights reserved.
//

import UIKit

extension UIImage {
    
    static let bundle = Bundle(for: PickerViewController.self)
    
    static func chevron() -> UIImage {
        return UIImage(named: "chevron", in: bundle, compatibleWith: nil)!
    }
    
    static func indent() -> UIImage {
        return UIImage(named: "indent", in: bundle, compatibleWith: nil)!
    }
    
    static func `return`() -> UIImage {
        return UIImage(named: "return", in: bundle, compatibleWith: nil)!
    }
}

extension UINavigationController {
    
    public func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping (() -> Void)) {
        pushViewController(viewController, animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    public func popViewController(animated: Bool, completion: @escaping (() -> Void)) {
        popViewController(animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}

extension UIColor {
    static func ios13LabelColor() -> UIColor {
        if UIScreen.main.traitCollection.userInterfaceStyle == .light {
            return .darkText
        } else {
            return .lightText
        }
    }
}

extension UIViewController {
    
    public var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func set(epTitle title:String, epSubTitle subtitle:String?) {
        
        let topBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 44 // when i'm a controller that is presented modally i won't have a nc
        
        // adjust y for subtitle == nil
        var variableY: CGFloat = subtitle == nil ? 4 : -2
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: variableY, width: 0, height: 0))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = UIColor.ios13LabelColor()
        titleLabel.font = .systemFont(ofSize: 17 * EPSizeManager.shared().multiplier, weight: .bold)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        
        variableY += titleLabel.frame.size.height
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: variableY, width: 0, height: 0))
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 12 * EPSizeManager.shared().multiplier)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        
        var width = max(titleLabel.frame.size.width, subtitleLabel.frame.size.width)
        if width > 170 {
            width = 170
        }
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: topBarHeight))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        titleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["title": titleLabel, "sub": subtitleLabel]))
        titleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sub]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["title": titleLabel, "sub": subtitleLabel]))
        titleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[title][sub]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["title": titleLabel, "sub": subtitleLabel]))
        
        navigationItem.titleView = titleView
    }
}

class EPSizeManager {
    
// Family & Model            Logical Width    Logical Height    Physical Width    Physical Height    PPI    Retina Factor    Release
// iPhone 11 Pro Max              414               896              1242               2688         458          3         2019-09-20
// iPhone 11 Pro                  375               812              1125               2436         458          3         2019-09-20
// iPhone 11                      414               896              828                1792         326          2         2019-09-20
// iPhone XR                      414               896              828                1792         326          2         2018-10-26
// iPhone XS Max                  414               896              1242               2688         458          3         2018-09-21
// iPhone XS                      375               812              1125               2436         458          3         2018-09-21
// iPhone X                       375               812              1125               2436         458          3         2017-11-03
// iPhone 8 Plus                  414               736              1242               2208         401          3         2017-09-22
// iPhone 8                       375               667              750                1334         326          2         2017-09-22
// iPhone 7 Plus                  414               736              1242               2208         401          3         2016-09-16
// iPhone 7                       375               667              750                1334         326          2         2016-09-16
// iPhone SE                      320               568              640                1136         326          2         2016-03-31
// iPhone 6s Plus                 414               736              1242               2208         401          3         2015-09-25
// iPhone 6s                      375               667              750                1334         326          2         2015-09-25
// iPhone 6 Plus                  414               736              1242               2208         401          3         2014-09-19
// iPhone 6                       375               667              750                1334         326          2         2014-09-19
// iPhone 5c                      320               568              640                1136         326          2         2013-09-20
// iPhone 5s                      320               568              640                1136         326          2         2013-09-20
// iPhone 5                       320               568              640                1136         326          2         2012-09-21
// iPhone 4S                      320               480              640                960          326          2         2011-10-14
// iPhone 4                       320               480              640                960          326          2         2010-06-21
// iPhone 3GS                     320               480              320                480          163          1         2009-06-19
// iPhone 3G                      320               480              320                480          163          1         2008-07-11
// iPhone 1st gen                 320               480              320                480          163          1         2007-06-29
// iPod touch 6th gen             320               568              640                1136         326          2         2015-07-15
// iPod touch 5th gen             320               568              640                1136         326          2         2012-10-11
// iPod touch 4th gen             320               480              640                960          326          2         2010-09-01
// iPod touch 3rd gen             320               480              320                480          163          1         2009-09-09
// iPod touch 2nd gen             320               480              320                480          163          1         2008-09-09
// iPod touch 1st gen             320               480              320                480          163          1         2007-09-05
// iPad 2018                      768               1024             1536               2048         264          2         2018-03-27
// iPad Pro (2nd gen 12.9")       1024              1366             2048               2732         264          2         2017-06-13
// iPad Pro (2nd gen 10.5")       834               1112             1668               2224         264          2         2017-06-13
// iPad 2017                      768               1024             1536               2048         264          2         2017-03-24
// iPad Pro (1st gen 9.7”)        768               1024             1536               2048         264          2         2016-03-31
// iPad Pro (1st gen 12.9")       1024              1366             2048               2732         264          2         2015-11-11
// iPad mini 4                    768               1024             1536               2048         326          2         2015-09-09
// iPad Air 2                     768               1024             1536               2048         326          2         2014-10-22
// iPad mini 3                    768               1024             1536               2048         264          2         2014-10-22
// iPad mini 2                    768               1024             1536               2048         326          2         2013-11-12
// iPad Air                       768               1024             1536               2048         264          2         2013-11-01
// iPad 4th gen                   768               1024             1536               2048         264          2         2012-11-12
// iPad mini                      768               1024             768                1024         163          1         2012-11-02
// iPad 3rd gen                   768               1024             1536               2048         264          2         2012-03-16
// iPad 2                         768               1024             768                1024         132          1         2011-03-11
// iPad 1st gen                   768               1024             768                1024         132          1         2010-04-03
   
    private static let sharedManager = EPSizeManager() // lazy singleton
    
    var multiplier: CGFloat = 1.0
    private let _largestPossibleRatio: CGFloat = 1.3
    private let _smallestPossibleRatio: CGFloat = 0.8
    
    class func shared() -> EPSizeManager {
        return sharedManager
    }
    
    init() {
        let smallerDeviceDimension: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let base: CGFloat = 414 // iphone 11 width
        let ratio = smallerDeviceDimension / base
        if ratio > _largestPossibleRatio {
            multiplier = _largestPossibleRatio
        } else if ratio < _smallestPossibleRatio {
            multiplier = _smallestPossibleRatio
        } else {
            multiplier = ratio
        }
    }
}
