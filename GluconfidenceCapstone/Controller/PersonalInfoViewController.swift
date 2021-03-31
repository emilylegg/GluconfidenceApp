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
    
    @IBOutlet weak var typeInput: DropDown!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var zipInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var sexInput: UITextField!
    @IBOutlet weak var weightInput: UITextField!
    //@IBOutlet weak var typeInput: UITextField!
    @IBOutlet weak var yearInput: UITextField!
    @IBOutlet weak var medInput: UITextField!
    @IBOutlet weak var insulinInput: UITextField!
    @IBOutlet weak var dailyInput: UITextField!
    @IBOutlet weak var activeInput: UITextField!
    @IBOutlet weak var glubottleInput: UITextField!
    @IBOutlet weak var groupInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
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
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
