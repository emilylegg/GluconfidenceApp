//
//  TreatmentViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/4/21.
//

import Foundation
import SwiftUI
import UIKit

class TreatmentViewController: UIViewController {
    //Goal will be to have a checklist to see what was
    //Treated w/ GC and not GC
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    //   @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var checkList: UIStackView!
    
    @IBOutlet weak var refill: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       setMenuBtn(menuBtn)
        title = "Treatment View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
}
