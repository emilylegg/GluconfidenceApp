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
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        let count = 0 //will equal the number of low events
        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
         title = "Calendar View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    
    
    
    let da = Date()
    
    func getInfoForCalendar(){
        
        // set up dateformatter
       // let dateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        // this will set the timezone to be in UTC so that converted strings will be in UTC as well
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // testing parameters
        let userid = 3
        let count = 3
        let month = 3
        let year = 2021
//        let beginTime = "2021-04-07 00:00:00"
//        let endTime = "2021-04-07 23:59:00"
        
        // endDate is begining of today
        let endDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: da)) ?? da
        // startDate is begining of yesterday
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let startDate: Date = Calendar.current.date(byAdding: dayComponent, to: endDate) ?? da
        print(startDate)
        
        print(endDate)
        
        let beginTime = formatter.string(from: startDate)
        let endTime = formatter.string(from: endDate)
        let calendarcounts = NSMutableArray()
        
        //print(beginTime)
       // print(endTime)
        
 //       let parameters = ["UserID": userid, "beginTime": beginTime, "endTime": endTime]
        guard let url = URL(string: "http://192.168.64.2/gluconfidence/calendar.php") else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: String.Encoding.utf8) else {return}
//        request.httpBody = httpBody
        let paramString = "UserID=" + String(userid) + "Month=" + String(month) + "Year=" + String(year)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
//            if let response = response{
//                print(response)
//            }
            if let data = data{
//                    let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                
                var jsonResult = NSArray()
                
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                } catch let error as NSError {
                    print(error)
                    
                }

                var jsonElement = NSDictionary()
                for row in jsonResult{
                    jsonElement = row as! NSDictionary
                    print(jsonElement["systemTime"]!)
//                   if let date = dateFormatter.date(from: jsonElement["systemTime"] as! String) {
//                        print(date.timeIntervalSince1970)
//                    }
//                    print(jsonElement["value"]!)
                }
            }
        }.resume()
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor{
        let count = 1
        if(count==0){
                   return UIColor.green
               }
               if(count==1){
                   return UIColor.yellow
               }
               if(count==2){
                   return UIColor.orange
               }
               if(count>=3){
                   return UIColor.red
               }
    }
}
