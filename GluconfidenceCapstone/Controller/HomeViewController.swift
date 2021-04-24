//
//  HomeViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/3/21.
//

import Foundation
import UIKit
import SwiftUI
import Charts

class HomeViewController: UIViewController {
   // @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var refill: UIButton!
    //@IBOutlet weak var refill: UIButton!
  //  @IBOutlet weak var quickNumber: UILabel!
  //  @IBOutlet weak var trend: UIImageView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var homeSnapshot: LineChartView!
    @IBOutlet weak var highBar: UIProgressView!
    @IBOutlet weak var rangeBar: UIProgressView!
    @IBOutlet weak var lowBar: UIProgressView!
    @IBOutlet weak var sevBar: UIProgressView!
    @IBOutlet weak var segmentHome: UISegmentedControl!
    @IBOutlet weak var mgDL: UILabel!
    
    @IBOutlet weak var highPercent: UILabel!
    @IBOutlet weak var rangePercent: UILabel!
    @IBOutlet weak var belowPercent: UILabel!
    @IBOutlet weak var lowPercent: UILabel!
    
    let userid = (UserDefaults.standard.value(forKey: "userid") as? Int) ?? 0
    
    var priordays = 1
    var token = ""
    
    let parameters = ["targetRanges": [
        [
          "name": "day",
          "startTime": "06:00:00",
          "endTime": "22:00:00",
          "egvRanges": [
            [
              "name": "urgentLow",
              "bound": 55
            ],
            [
              "name": "low",
              "bound": 70
            ],
            [
              "name": "high",
              "bound": 180
            ]
          ]
        ],
        [
          "name": "night",
          "startTime": "22:00:00",
          "endTime": "06:00:00",
          "egvRanges": [
            [
              "name": "urgentLow",
              "bound": 55
            ],
            [
              "name": "low",
              "bound": 70
            ],
            [
              "name": "high",
              "bound": 180
            ]
          ]
        ]
      ]] as [String : Any]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
        title = "Home View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        
        refill.layer.masksToBounds = true

        //segmentHome.backgroundColor = .success
//        quickNumber.backgroundColor = UIColor(patternImage: UIImage(named: "even")!)
//        quickNumber.text = "75" + "\n mg/dL"
//        quickNumber.center.x = self.view.center.x
//        trend.image = UIImage(named: "even")
        
        setupChart()
        getPoints()
        startHomeApi()
//        print(userid)
        
        
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    let today = Date()
    
    func getPoints(){
        
        // set up dateformatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // this will set the timezone to be in UTC so that converted strings will be in UTC as well
       dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // endDate is begining of today
        let endDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: today)) ?? today
        // startDate is begining of yesterday
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let startDate: Date = Calendar.current.date(byAdding: dayComponent, to: endDate) ?? today
        
        let beginTime = dateFormatter.string(from: startDate)
        let endTime = dateFormatter.string(from: endDate)
        let timepoints = NSMutableArray()
        
        
        guard let url = URL(string: "http://192.168.64.2/gluconfidence/home_24.php") else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let paramString = "UserID=" + String(userid) + "&beginTime=" + beginTime + "&endTime=" + endTime
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let sem = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            defer { sem.signal() }
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
                    let timepoint = TimestampModel(time: jsonElement["systemTime"] as! String, value: Int(jsonElement["value"] as! String) ?? 0)
                    timepoints.add(timepoint)
//                    print(timepoint.description)
                }
                
            }
            
        }.resume()
        
        sem.wait()
        setupChartData(timeData: timepoints, dateFormatter: dateFormatter)
        
    }
    
    private func setupChart() {
        let leftAxis = homeSnapshot.leftAxis
        leftAxis.axisMinimum = 50
        leftAxis.axisMaximum = 300
        leftAxis.granularity = 50
        
        let rightAxis = homeSnapshot.rightAxis
        rightAxis.enabled = false
        
        // endDate is begining of today
        let endDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: today)) ?? today
        // startDate is begining of yesterday
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let startDate: Date = Calendar.current.date(byAdding: dayComponent, to: endDate) ?? today
        
        let xAxis = homeSnapshot.xAxis
        xAxis.valueFormatter = TimeValueFormatter()
        xAxis.axisMinimum = startDate.timeIntervalSince1970
    
        
        xAxis.axisMaximum = endDate.timeIntervalSince1970
        xAxis.labelPosition = .bottom
        xAxis.granularity = 14400

        homeSnapshot.legend.enabled = false
        homeSnapshot.setVisibleXRange(minXRange: 6 * 14400, maxXRange: 6 * 14400)
    }
        
    private func setupChartData(timeData: NSMutableArray, dateFormatter: DateFormatter) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<timeData.count {
            let data = timeData[i] as! TimestampModel
            let date = dateFormatter.date(from: data.time!)
            let dataEntry = ChartDataEntry(x: date!.timeIntervalSince1970, y: Double(data.value!))
                dataEntries.append(dataEntry)
        }
        if timeData.count > 0 {
            let dataSet = LineChartDataSet(entries: dataEntries, label: "")
            dataSet.mode = .cubicBezier
    //        dataSet.fillAlpha = 0.5
    //        dataSet.drawFilledEnabled = true
    //        dataSet.drawVerticalHighlightIndicatorEnabled = false
    //        dataSet.drawHorizontalHighlightIndicatorEnabled = false
    //        dataSet.highlightEnabled = false
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            dataSet.lineWidth = 2
            let data = LineChartData(dataSet: dataSet)
            homeSnapshot.data = data
        }
    }
    
    func startHomeApi(){
        
        guard let url = URL(string: "http://192.168.64.2/gluconfidence/home_api.php") else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let paramString = "UserID=" + String(userid)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let semToken = DispatchSemaphore(value: 0)
        
        let sessionToken = URLSession.shared
        sessionToken.dataTask(with: request) { (data, response, error) in
            defer { semToken.signal() }
            if let data = data{
                
                do{
                    self.token = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? String ?? ""
                    
                } catch let error as NSError {
                    print(error)
                    
                }
                
            }
            
        }.resume()
        
        semToken.wait()
        apiPercentages(tokenString: token)
//        print(token)
    }
    
    
    func apiPercentages(tokenString: String){
        
        var percentBelowRange = Float()
        var percentAboveRange = Float()
        var percentUrgentLow = Float()
        var percentWithinRange = Float()
        
        let authorizationToken = "Bearer " + tokenString
        let sem = DispatchSemaphore(value: 0)

        let headers = [
          "authorization": authorizationToken,
          "content-type": "application/json"
        ]
        

        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let endTime: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: today)) ?? today
        
        var dayComponent = DateComponents()
        dayComponent.day = -priordays
        let startTime: Date = Calendar.current.date(byAdding: dayComponent, to: endTime) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // convert time zone to utc if api request is base on utc time
//       dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let startDate = dateFormatter.string(from: startTime)
        let endDate = dateFormatter.string(from: endTime)
        
//        print(startDate)
//        print(endDate)
        
        let apiUrl = "https://api.dexcom.com/v2/users/self/statistics?" + "startDate=" + startDate + "&endDate=" + endDate
        
        let request = NSMutableURLRequest(url: NSURL(string: apiUrl)! as URL,
              cachePolicy: .useProtocolCachePolicy,
          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData! as Data
    
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            defer { sem.signal() }
            
            if (error != nil) {
                print(error!)
          } else {
//            let httpResponse = response as? HTTPURLResponse
//            print(httpResponse)
            do {
                let httpData = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//                print(httpData)
                
                percentUrgentLow = (httpData["percentUrgentLow"] as? NSNumber)?.floatValue ?? 0
                percentWithinRange = (httpData["percentWithinRange"] as? NSNumber)?.floatValue ?? 0
                percentBelowRange = (httpData["percentBelowRange"] as? NSNumber)?.floatValue ?? 0
                percentAboveRange = (httpData["percentAboveRange"] as? NSNumber)?.floatValue ?? 0
                
                
            }catch let errorP as NSError {
                print(errorP)
            }
          }
        })

        dataTask.resume()
        
        sem.wait()
        plotbars(above: percentAboveRange,within: percentWithinRange,below: percentBelowRange,low: percentUrgentLow)
    }
    
    private func plotbars(above: Float, within: Float, below: Float, low: Float) {
        
        lowBar.setProgress(below/100, animated: false)
        rangeBar.setProgress(within/100, animated: false)
        sevBar.setProgress(low/100, animated: false)
        highBar.setProgress(above/100, animated: false)
 
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        
        highPercent.text = (formatter.string(for: above) ?? "0") + "%"
        rangePercent.text = (formatter.string(for: within) ?? "0") + "%"
        belowPercent.text = (formatter.string(for: below) ?? "0") + "%"
        lowPercent.text = (formatter.string(for: low) ?? "0") + "%"
        
    }
    

    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            priordays = 1
            
        }else if sender.selectedSegmentIndex == 1 {
            priordays = 7
        }else{
            priordays = 30
        }
        apiPercentages(tokenString: token)
    }
    
}
