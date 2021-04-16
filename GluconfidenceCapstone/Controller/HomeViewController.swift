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
//        setupChartData()
        getPoints()
        apiPercentages()
        
        
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
        
        // testing parameters
        let userid = 3
        
        // endDate is begining of today
        let endDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: today)) ?? today
        // startDate is begining of yesterday
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let startDate: Date = Calendar.current.date(byAdding: dayComponent, to: endDate) ?? today
//        print(startDate)
//        print(endDate)
        
        let beginTime = dateFormatter.string(from: startDate)
        let endTime = dateFormatter.string(from: endDate)
        let timepoints = NSMutableArray()
        
 //       let parameters = ["UserID": userid, "beginTime": beginTime, "endTime": endTime]
        guard let url = URL(string: "http://192.168.64.2/gluconfidence/home_24.php") else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: String.Encoding.utf8) else {return}
//        request.httpBody = httpBody
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
//                    print(jsonElement["systemTime"]!)
//                   if let date = dateFormatter.date(from: jsonElement["systemTime"] as! String) {
//                        print(date.timeIntervalSince1970)
//                    }
//                    print(Int(jsonElement["value"] as! String) ?? 0)
                    let timepoint = TimestampModel(time: jsonElement["systemTime"] as! String, value: Int(jsonElement["value"] as! String) ?? 0);
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
    //        dataSet.setColor(.white)
    //        dataSet.fill = Fill(color: .blue)
    //        dataSet.fillAlpha = 0.5
    //        dataSet.drawFilledEnabled = true
            dataSet.drawCirclesEnabled = false
            dataSet.lineWidth = 2
            
            let data = LineChartData(dataSet: dataSet)
            homeSnapshot.data = data
        }
    }
    
    func apiPercentages(){
        
        var percentBelowRange = Float()
        var percentAboveRange = Float()
        var percentUrgentLow = Float()
        var percentWithinRange = Float()
        
        // going to replace the access token below using result from POST request
        let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImFPcnJObFpZUmRES0stemZmWEZwTXZZN18wZyIsImtpZCI6ImFPcnJObFpZUmRES0stemZmWEZwTXZZN18wZyJ9.eyJpc3MiOiJodHRwczovL3VhbTEuZGV4Y29tLmNvbS9pZGVudGl0eSIsImF1ZCI6Imh0dHBzOi8vdWFtMS5kZXhjb20uY29tL2lkZW50aXR5L3Jlc291cmNlcyIsImV4cCI6MTYxODU2NTg5NywibmJmIjoxNjE4NTU4Njk3LCJjbGllbnRfaWQiOiJNbmhDYU5FdDlYcVY5MkJwZTZtVzR6MGtUWlpkMjlFUCIsInN1YiI6IjZiNDczOTcwLTY3OTItNDhhNS04ZDlhLTY4MTUwY2QyNTUyMSIsImF1dGhfdGltZSI6IjE2MTU5NTgxNjQiLCJpZHAiOiJpZHNydiIsIm1pc3NpbmdfZmllbGRzX2NvdW50IjoiMCIsImp0aSI6ImQwYTYzOTc5Njk5YTgzYWRiZTY4ODUzNjUwODM3ODQzIiwic2NvcGUiOlsiY2FsaWJyYXRpb24iLCJldmVudCIsIm9mZmxpbmVfYWNjZXNzIiwiZWd2Iiwic3RhdGlzdGljcyIsImRldmljZSJdLCJpc19jb25zZW50X3JlcXVpcmVkIjoiZmFsc2UiLCJjbnN0IjoiMiIsImNuc3RfY2xhcml0eSI6IjIiLCJjbnN0X3RlY2hzdXBwb3J0IjoiMiIsImNvdW50cnlfY29kZSI6IlVTIiwiYW1yIjpbInBhc3N3b3JkIl19.YkofBxrySjHQ1NoG3SQuV6IDJtu5rDJqT3YyYu6Fq6m8R9EUwxtxGXnYH2-dskOiKkDYCi8YjBQf7Y2iBGHFlHr5hpBs8KHBmEnE9uz5K4geaWr0Nw_nqYi_UnjCdeQbOkEc-9ulQ2mVbheWv5bzQaFDETdC5k3bXuF1asMAGyhEGP63NjI6bgQ8PED_B0QYTjF0AWUJl8YjRVyCr9YdczZYC7ZtNSbsWVhjuSWCLLdcwuW8Yw-svmLp4-1wM7GlKR9v8pA43tAP7A1NZSLSsFmrZyTwiKEvOpBS7tk8JNnuErUJQYLUYhxGTWSet2Uo1-_hQqQH9tVms1XaGIlnug"
        
        let authorizationToken = "Bearer " + accessToken
        let sem = DispatchSemaphore(value: 0)

        let headers = [
          "authorization": authorizationToken,
          "content-type": "application/json"
        ]
        

        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.dexcom.com/v2/users/self/statistics?startDate=2021-04-15&endDate=2021-04-16")! as URL,
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
                print(httpData)
                
                percentUrgentLow = (httpData["percentUrgentLow"] as? NSNumber)?.floatValue ?? 0
                percentWithinRange = (httpData["percentWithinRange"] as? NSNumber)?.floatValue ?? 0
                percentBelowRange = (httpData["percentBelowRange"] as? NSNumber)?.floatValue ?? 0
                percentAboveRange = (httpData["percentAboveRange"] as? NSNumber)?.floatValue ?? 0
                
//                print(percentAboveRange);
//                print(percentWithinRange);
//                print(percentBelowRange)
//                print(percentUrgentLow);
                
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
    
}
