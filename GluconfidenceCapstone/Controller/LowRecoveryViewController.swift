//
//  LowRecoveryViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/25/21.
//

import Foundation
import UIKit

class LowRecoveryViewController: UIViewController {
    
  //  @IBOutlet weak var refill: UIButton!
   // @IBOutlet weak var menuBtn: UIBarButtonItem!
    
  //  @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         setMenuBtn(menuBtn)
         title = "Low Recovery View"
        //refill.layer.cornerRadius = refill.frame.size.width/2
        //refill.layer.shadowRadius = 1
       // refill.layer.shadowOpacity = 0.5
        //refill.layer.masksToBounds = true
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
