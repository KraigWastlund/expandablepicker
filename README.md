# ExpandablePicker

[![CI Status](https://img.shields.io/travis/FishbowlInventory/ExpandablePicker.svg?style=flat)](https://travis-ci.org/FishbowlInventory/ExpandablePicker)
[![Version](https://img.shields.io/cocoapods/v/ExpandablePicker.svg?style=flat)](https://cocoapods.org/pods/ExpandablePicker)
[![License](https://img.shields.io/cocoapods/l/ExpandablePicker.svg?style=flat)](https://cocoapods.org/pods/ExpandablePicker)
[![Platform](https://img.shields.io/cocoapods/p/ExpandablePicker.svg?style=flat)](https://cocoapods.org/pods/ExpandablePicker)

## High Points
- Select any item in the list.
- Conform to delegate and get notified when something is picked.
- Expand and Contract based on `parentId`.
- Sorting happens for you (alphabetically ascending).
- Can be presented Modal/Push.
- Color of Chevron Button can be customized.
- Pick from three built in styling options:  
  - Line
  - Arrow (no indent image on root level)
  - None (no indentation image)
  - Custom (pass your own image)
- Custom indentation type can have an optional 'expanded image' and animation will result.
- Colors of indentation image can be customized for each level of indentation.
- Works in Dark mode and Light.
- Works in landscape and portrait.
- Barcode / QRCode Scanning!  

## Example

Motion-
:-------------------------:|
![picture](https://raw.githubusercontent.com/FishbowlInventory/ExpandablePicker/master/ReadMeResources/1.gif) |


Line Indent Type | Arrow Indent Type | None Indent Type | Custom Indent Type | Search
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![picture](https://raw.githubusercontent.com/FishbowlInventory/ExpandablePicker/master/ReadMeResources/1.png)  |  ![picture](https://raw.githubusercontent.com/FishbowlInventory/ExpandablePicker/master/ReadMeResources/2.png)  |  ![picture](https://raw.githubusercontent.com/FishbowlInventory/ExpandablePicker/master/ReadMeResources/3.png)  |  ![picture](https://raw.githubusercontent.com/FishbowlInventory/ExpandablePicker/master/ReadMeResources/4.png)  |  ![picture](https://raw.githubusercontent.com/FishbowlInventory/ExpandablePicker/master/ReadMeResources/5.png) 

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS > 12.0

## Installation

ExpandablePicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ExpandablePicker'
```

## Usage
```swift
import UIKit
import ExpandablePicker

struct Project {
    let id: String
    let title: String
    let parentId: String?
}

class ViewController: UIViewController {
    
    var myPretendData = [Project]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // my pretend api call
        // populate my data
        let deathStar = Project(id: "1", title: "Death Star", parentId: nil)
        let detentionBlock = Project(id: "10", title: "Detention Block", parentId: "1")
        let cellaa23 = Project(id: "100", title: "Cell AA-23", parentId: "10")
        let emperorsThroneRoom = Project(id: "11", title: "Emperor's Throne Room", parentId: "1")
        let tractorBeamControl = Project(id: "12", title: "Tractor Beam Control", parentId: "1")
        let hangar272 = Project(id: "13", title: "Hangar 272", parentId: "1")
        
        // if you want barcode / qr code scanning, add `scanMatchable:` paramter.  (any string you pass in that array will match barcode/qrcode)
        
        // does not matter what order items are placed
        myPretendData.append(contentsOf: [hangar272, cellaa23, detentionBlock, tractorBeamControl, deathStar, emperorsThroneRoom])
    }
    
    @IBAction func lineVersionPressed(_ sender: Any) {
        
        // convert data to picker data
        let pickerData = myPretendData.map { (project) -> PickerData in
            PickerData(id: project.id, title: project.title, parentId: project.parentId)
        }
        
        let vc = PickerViewController()
        vc.set(title: "My Storm Trooper", subtitle: "Death to all rebels")
        vc.datasource.data = pickerData
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
}

extension ViewController: PickerProtocol {
    
    func didSelectPickerData(with id: String, pvc: PickerViewController) {
        
        guard let d = myPretendData.filter({ $0.id == id }).first else { return }
        
        pvc.dismiss(animated: true) { [weak self] in
            guard let s = self else { return }
            let alert = UIAlertController(title: "Selected", message: "\(d.title) was selected.", preferredStyle: .alert)
            s.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
```

## Author

Fishbowl Inventory (KraigWastlund)

## License

ExpandablePicker is available under the MIT license. See the LICENSE file for more info.
