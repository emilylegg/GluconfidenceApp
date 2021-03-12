//
//  HomeViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/3/21.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var refill: UIButton!
    @IBOutlet weak var quickNumber: UILabel!
    @IBOutlet weak var trend: UIImageView!
    
    @IBOutlet weak var mgDL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
        title = "Home View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
//        quickNumber.backgroundColor = UIColor(patternImage: UIImage(named: "even")!)
        quickNumber.text = "75" + "\n mg/dL"
//        quickNumber.center.x = self.view.center.x
        trend.image = UIImage(named: "even")
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    

}
