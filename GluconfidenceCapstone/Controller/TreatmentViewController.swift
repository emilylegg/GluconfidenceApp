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
    
    let userid = (UserDefaults.standard.value(forKey: "userid") as? Int) ?? 0
    let lowNullGC = NSMutableArray()
    
    @IBOutlet weak var refill: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var numberBottles: UITextField!
    
    let formatterHour = DateFormatter()
    let formatterDate = DateFormatter()
    
    //@IBOutlet weak var takeTreatment: DropDown!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        getNullLows()
        
        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
        title = "Treatment View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
        formatterHour.locale = Locale(identifier: "en_US_POSIX")
        formatterHour.dateFormat = "MM-dd hh:mm a"
        formatterHour.amSymbol = "AM"
        formatterHour.pmSymbol = "PM"
        
        formatterDate.locale = Locale(identifier: "en_US_POSIX")
        formatterDate.timeZone = TimeZone(secondsFromGMT: 0)
        formatterDate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //takeTreatment.optionArray = ["5 min", "10 min", "15 min"]
        
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func getNullLows(){
        guard let url = URL(string: "http://192.168.64.2/gluconfidence/Treatment_load.php") else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let paramString = "UserID=" + String(userid)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let sem = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        session.dataTask(with: request) { [self] (data, response, error) in
            defer { sem.signal() }
//            if let response = response{
//                print(response)
//            }
            if let data = data{
                var jsonResult = NSArray()
                
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                } catch let error as NSError {
                    print(error)
                    
                }

                var jsonElement = NSDictionary()
                for row in jsonResult{
                    jsonElement = row as! NSDictionary
                    
                    self.lowNullGC.add(jsonElement["Low_Start_Time"] as! String)
//                    print(timepoint.description)
                }
                
            }
            
        }.resume()
        
        sem.wait()
//        self.tableView.reloadData()
//        print(lowNullGC)
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
        return lowNullGC.count
      }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let lowDate = formatterDate.date(from: lowNullGC[indexPath.row] as! String)!
        
        cell.textLabel?.text = formatterHour.string(from: lowDate)
        //cell.textLabel?.color = .gray
//        print(lowNullGC[indexPath.row])
//        print(formatter.string(for: lowNullGC[indexPath.row]))
        
        return cell
      }
    
    func completeAction(at indexPath: IndexPath)-> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            self.updateGCAction(action: 1, index: indexPath.row)
            self.lowNullGC.removeObject(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(named: "2")
        action.backgroundColor = UIColor(named: "HamBand")
        return action
    }
    
    func notGluAction(at indexPath: IndexPath)-> UIContextualAction {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let action = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            //cell.remove(at: indexPath.row)
            self.updateGCAction(action: 0, index: indexPath.row)
            self.lowNullGC.removeObject(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(named: "3")
        action.backgroundColor = UIColor(named: "Danger")
        return action
    }
    
    func updateGCAction(action: Int, index: Int){
        let sem = DispatchSemaphore(value: 0)
        let url = URL(string: "http://192.168.64.2/gluconfidence/Treatment_update.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let lowTime = lowNullGC[index] as! String
        let paramString = "UserID=" + String(userid) + "&IsGC=" + String(action) + "&LowTime=" + lowTime
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            defer { sem.signal() }
            
            if let data = data{
                var updateResult = NSDictionary()
                
                do{
                    updateResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                } catch let error as NSError {
                    print(error)
                    
                }
                if(updateResult["error"] as! NSNumber == 0){
                    print(updateResult["message"]!)
                }else{
                    print(updateResult["message"]!)
                }
            }
            
        }.resume()
        sem.wait()
    }
}
