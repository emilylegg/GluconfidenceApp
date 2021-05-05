//
//  PersonalInfoViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/25/21.
//

import Foundation
import UIKit
import iOSDropDown
import SwiftUI

class PersonalInfoViewController: UIViewController {
    
    @IBOutlet weak var refill: UIButton!
    
    @IBOutlet weak var groupInput: DropDown!
    @IBOutlet weak var activeInput: DropDown!
    @IBOutlet weak var dailyInput: DropDown!
    @IBOutlet weak var medInput: DropDown!
    @IBOutlet weak var sexInput: DropDown!
    @IBOutlet weak var typeInput: DropDown!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var zipInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var yearInput: UITextField!
    @IBOutlet weak var insulinInput: UITextField!
    @IBOutlet weak var glubottleInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let userid = (UserDefaults.standard.value(forKey: "userid") as? Int) ?? 0

    //@IBOutlet weak var refill: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
         title = "Personal Info View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 5
        
        medInput.optionArray = ["DPP-4 Inhibitor", "SGLT2 Inhibitor","Metforrmin", "None","Other"]
        typeInput.optionArray = ["1","2", "Prediabetic"]
        groupInput.optionArray = ["Yes please", "No thank you"]
        sexInput.optionArray = ["Male", "Female"]    //put in a "why am I seeing this"
        dailyInput.optionArray = ["1", "2", "3", "4", "5", "6+", "pump/podd"]
        activeInput.optionArray = ["No Activity", "2-3 times a week 20-30 min", "3+ times a week 30+ min", "5+ times a week 30+ min","6+ times a week"]
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
