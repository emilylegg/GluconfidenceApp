//
//  UserDisclaimerViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/7/21.
//

import Foundation
import UIKit

class UserDisclaimerViewController: UIViewController {
    

    @IBOutlet weak var buttonCheck: CheckBox!
    
    @IBOutlet weak var buttonNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func checkSwitch(_ sender: Any) {
        buttonNext.isEnabled = !(buttonCheck.isChecked)
    }


}
