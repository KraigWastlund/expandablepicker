//
//  ViewController.swift
//  ExpandablePicker
//
//  Created by Kraig Wastlund on 8/4/20.
//  Copyright © 2020 Fishbowl Inventory. All rights reserved.
//

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
        
        // does not matter what order it's placed
        myPretendData.append(contentsOf: [hangar272, cellaa23, detentionBlock, tractorBeamControl, deathStar, emperorsThroneRoom])
    }
    
    @IBAction func lineVersionPressed(_ sender: Any) {
        
        // convert data to picker data
//        let pickerData = myPretendData.map { (project) -> PickerData in
//            PickerData(id: project.id, title: project.title, parentId: project.parentId)
//        }
//
//        let vc = PickerViewController()
//        vc.set(title: "My Storm Trooper", subtitle: "Death to all rebels")
//        vc.datasource.data = pickerData
//        vc.delegate = self
//        let nc = UINavigationController(rootViewController: vc)
//        present(nc, animated: true, completion: nil)
        
        // set style
        PickerStyle.indentType = .line
        PickerStyle.set(indentImageTintColors: [.blue, .green, .yellow, .lightGray, .red])

        // vanilla
        let vc = PickerViewController()
        vc.set(title: "Vanilla", subtitle: nil)
        vc.datasource.data = datasource()
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @IBAction func arrowVersionPressed(_ sender: Any) {
        
        // set style
        PickerStyle.indentType = .arrow
        PickerStyle.set(indentImageTintColors: [.red, .green])
        
        // arrow indent image
        // root has no image
        let vc = PickerViewController()
        vc.delegate = self
        vc.title = "No Root"
        vc.datasource.data = datasource()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func noneVersionPressed(_ sender: Any) {
        
        // set style
        PickerStyle.indentType = .none
        PickerStyle.set(chevronButtonTintColorDark: .red, chevronButtonTintColorLight: .red)
        
        // no indent images at all
        let vc = PickerViewController()
        vc.delegate = self
        vc.set(title: "No Indent", subtitle: "Here's a really long sub title just for funzies.")
        vc.datasource.data = datasource(rootImageNormal: nil, childImageNormal: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func customPressed(_ sender: Any) {
        
        // set style
        PickerStyle.indentType = .custom
        PickerStyle.set(chevronButtonTintColorDark: .purple, chevronButtonTintColorLight: .red)
        
        // no indent images at all
        let vc = PickerViewController()
        vc.delegate = self
        vc.set(title: "No Indent", subtitle: "Here's a really long sub title just for funzies.")
        let normal = #imageLiteral(resourceName: "box_closed")
        let expanded = #imageLiteral(resourceName: "box_open")
        vc.datasource.data = datasource(rootImageNormal: normal, rootImageExpanded: expanded, childImageNormal: normal, childImageExpanded: expanded)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func datasource(rootImageNormal: UIImage? = nil, rootImageExpanded: UIImage? = nil, childImageNormal: UIImage? = nil, childImageExpanded: UIImage? = nil) -> [PickerData] {
        
        // create picker data for example the old fashioned way. :)
        let one = PickerData(id: UUID().uuidString, title: "1", parentId: nil, indentImageNormal: rootImageNormal, indentImageExpanded: rootImageExpanded)
        let oneone = PickerData(id: UUID().uuidString, title: "1-1", parentId: one.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let onetwo = PickerData(id: UUID().uuidString, title: "1-2", parentId: one.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        let onetwoone = PickerData(id: UUID().uuidString, title: "1-2-1", parentId: onetwo.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        let onethree = PickerData(id: UUID().uuidString, title: "1-3", parentId: one.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let onefour = PickerData(id: UUID().uuidString, title: "1-4", parentId: one.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let onefive = PickerData(id: UUID().uuidString, title: "1-5", parentId: one.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let onesix = PickerData(id: UUID().uuidString, title: "1-6", parentId: one.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        let two = PickerData(id: UUID().uuidString, title: "2", parentId: nil, indentImageNormal: rootImageNormal, indentImageExpanded: rootImageExpanded)
        let twoone = PickerData(id: UUID().uuidString, title: "2-1", parentId: two.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let twotwo = PickerData(id: UUID().uuidString, title: "2-2", parentId: two.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        let three = PickerData(id: UUID().uuidString, title: "3", parentId: nil, indentImageNormal: rootImageNormal, indentImageExpanded: rootImageExpanded)
        let threeone = PickerData(id: UUID().uuidString, title: "3-1", parentId: three.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let threetwo = PickerData(id: UUID().uuidString, title: "3-2", parentId: three.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let threethree = PickerData(id: UUID().uuidString, title: "3-3", parentId: three.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        let four = PickerData(id: UUID().uuidString, title: "4", parentId: nil, indentImageNormal: rootImageNormal, indentImageExpanded: rootImageExpanded)
        let fourone = PickerData(id: UUID().uuidString, title: "4-1", parentId: four.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let fourtwo = PickerData(id: UUID().uuidString, title: "4-2", parentId: four.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let fourthree = PickerData(id: UUID().uuidString, title: "4-3", parentId: four.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let fourfour = PickerData(id: UUID().uuidString, title: "4-4", parentId: four.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        let project = PickerData(id: UUID().uuidString, title: "Project", parentId: nil, indentImageNormal: rootImageNormal, indentImageExpanded: rootImageExpanded)
        let subProject1 = PickerData(id: UUID().uuidString, title: "Sub Project 1", parentId: project.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let subProject2 = PickerData(id: UUID().uuidString, title: "Sub Project 2", parentId: subProject1.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let subProject3 = PickerData(id: UUID().uuidString, title: "Sub Project 3", parentId: subProject2.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let subProject4 = PickerData(id: UUID().uuidString, title: "Sub Project 4", parentId: subProject3.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let subProject5 = PickerData(id: UUID().uuidString, title: "Sub Project 5", parentId: subProject4.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        let subProject6 = PickerData(id: UUID().uuidString, title: "Sub Project 6", parentId: subProject5.id, indentImageNormal: childImageNormal, indentImageExpanded: childImageExpanded)
        
        return [subProject6, fourfour, fourtwo, fourone, subProject5, four, fourthree, one, oneone, subProject4, onetwo, project, onetwoone, onethree, onefour, onefive, onesix, two, subProject3, twoone, twotwo, three, threeone, threetwo, threethree, subProject2, subProject1]
    }
}

extension ViewController: PickerProtocol {
    
    func didSelectPickerData(with id: String, pvc: PickerViewController) {
        
        guard let d = myPretendData.filter({ $0.id == id }).first else { return }
        
        if pvc.isModal {
            pvc.dismiss(animated: true) { [weak self] in
                guard let s = self else { return }
                let alert = UIAlertController(title: "Selected", message: "\(d.title) was selected.", preferredStyle: .alert)
                s.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            navigationController?.popViewController(animated: true, completion: { [weak self] in
                guard let s = self else { return }
                let alert = UIAlertController(title: "Selected", message: "\(d.title) was selected.", preferredStyle: .alert)
                s.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}

