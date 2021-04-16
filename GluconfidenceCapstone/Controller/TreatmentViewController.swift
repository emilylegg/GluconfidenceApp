//
//  TreatmentViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/4/21.
//

import Foundation
import SwiftUI
import iOSDropDown
import UIKit

final class Cell {
    let time: String
    
    init(title: String) {
        self.time = title
    }
}
class TreatmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //var cells = [Cell]()
    //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)    //Goal will be to have a checklist to see what was
    //Treated w/ GC and not GC
    
   // @IBOutlet weak var cell: UITableViewCell!
    //let dropDown = DropDown()
    
    var num = 10
    
    @IBOutlet weak var refill: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var numberBottles: UITextField!
    
    //@IBOutlet weak var takeTreatment: DropDown!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
       setMenuBtn(menuBtn)
        title = "Treatment View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
        //takeTreatment.optionArray = ["5 min", "10 min", "15 min"]
        
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //let glu = gluAction(at: indexPath)
        let notGlu = notGluAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [notGlu])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = completeAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [complete])
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return num
      }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "6:30 PM"
        //cell.textLabel?.color = .gray
        
        return cell
      }
    
    func completeAction(at indexPath: IndexPath)-> UIContextualAction {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let action = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            //cell.remove(at: indexPath.row)
            self.num-=1
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(named: "bottle")
        action.backgroundColor = UIColor(named: "HamBand")
        return action
    }
    
    func notGluAction(at indexPath: IndexPath)-> UIContextualAction {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let action = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            //cell.remove(at: indexPath.row)
            self.num-=1
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(named: "not")
        action.backgroundColor = UIColor(named: "Danger")
        return action
    }
}
