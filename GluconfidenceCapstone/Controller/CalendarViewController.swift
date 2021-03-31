//
//  CalendarViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/10/21.
//

import Foundation
import FSCalendar

class CalendarViewController: UIViewController {
    //@ObservedObject private var calendarManager: MonthlyCalendarManager
    @IBOutlet weak var refill: UIButton!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
         title = "Calendar View"
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
