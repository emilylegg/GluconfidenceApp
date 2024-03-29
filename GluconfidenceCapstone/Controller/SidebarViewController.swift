//
//  SidebarViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/3/21.
//

import Foundation
import UIKit
import SwiftUI

class SidebarViewController: UIViewController {

    let firstname = (UserDefaults.standard.value(forKey: "firstname") as? String) ?? "There";

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         title = "Hello, " + firstname
    }

    @IBAction func CalendarActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "calendar_segue", sender: nil)
    }
    
    @IBAction func SummariesActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "summary_segue", sender: nil)
    }
    
    @IBAction func HomeActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "home_segue", sender: nil)
    }
        
    @IBAction func TreatmentActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "treatment_segue", sender: nil)
        
    }

    @IBAction func LowActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "low_segue", sender: nil)
    }
    
    @IBAction func InfoActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "info_segue", sender: nil)
        
    }
    
}
