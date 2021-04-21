//
//  CalendarViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/10/21.
//

import Foundation
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    //@ObservedObject private var calendarManager: MonthlyCalendarManager
    @IBOutlet weak var refill: UIButton!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var calendar: FSCalendar!
    let formatter = DateFormatter()
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

//        let count = 0 //will equal the number of low events
        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
         title = "Calendar View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
        calendar.delegate = self
        calendar.dataSource = self
        
        getInfoForCalendar()
        
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
//    let userid = 1
    let userid = (UserDefaults.standard.value(forKey: "userid") as? Int) ?? 0
    let calendarcounts = NSMutableArray()
    
    func getInfoForCalendar(){
        
        // testing parameters
        let month = 3
        let year = 2021

//        let calendarcounts = NSMutableArray()
        
        let sem = DispatchSemaphore(value: 0)
        

        // this is request & parameters for query based on month & year
//        let url = URL(string: "http://192.168.64.2/gluconfidence/Calendar.php")
//        let paramString = "UserID=" + String(userid) + "&Month=" + String(month) + "&Year=" + String(year)
        
        // this is request & parameters for query based on only year
        let url = URL(string: "http://192.168.64.2/gluconfidence/Calendar_year.php")
        let paramString = "UserID=" + String(userid) + "&Year=" + String(year)

        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            defer { sem.signal() }
            
            if let data = data{
                
                var jsonResult = NSArray()
                
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                } catch let error as NSError {
                    print(error)
                    
                }

                var jsonElement = NSDictionary()
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    self.calendarcounts.add(jsonElement)
                }
                
                
            }
        }.resume()
        sem.wait()
    }
    
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let dateString : String = dateFormatter1.string(from:date)

        if(self.calendarcounts.count > 0){
            for i in 0..<self.calendarcounts.count{
                let calendarDict = self.calendarcounts[i] as! NSDictionary
                if(calendarDict["DATE"] as! String == dateString){
                    if(calendarDict["COUNT"] as! Int == 1){
                        return UIColor.yellow
                    }else if(calendarDict["COUNT"] as! Int == 2){
                        return UIColor.orange
                        
                    }else if(calendarDict["COUNT"] as! Int >= 3){
                        return UIColor.red
                    }
                }
            }
        }else{
            return UIColor.green
        }

        return UIColor.green
    }
        
}
