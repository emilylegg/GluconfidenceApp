//
//  SummariesViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 3/3/21.
//

import Foundation
import UIKit
import SwiftUI
import Charts

class SummariesViewController: UIViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var refill: UIButton!

    @IBOutlet weak var chart1: LineChartView!
    @IBOutlet weak var chart2: LineChartView!
    @IBOutlet weak var chart3: LineChartView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setMenuBtn(menuBtn)
         title = "Summary View"
        refill.layer.cornerRadius = refill.frame.size.width/2
        refill.layer.shadowRadius = 1
        refill.layer.shadowOpacity = 0.5
        refill.layer.masksToBounds = true
        
        findPriorLows()
    }
    
    // MARK: Create function for menu Action
    func setMenuBtn(_ menuBar: UIBarButtonItem){
        menuBar.target = revealViewController()
        menuBar.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    let userid = (UserDefaults.standard.value(forKey: "userid") as? Int) ?? 0
    let lowEvents = NSMutableArray()
    
    func findPriorLows(){
        guard let url = URL(string: "http://192.168.64.2/gluconfidence/PriorLow_lows.php") else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let paramString = "UserID=" + String(userid)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let sem1 = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            defer { sem1.signal() }
//            if let response = response{
//                print(response)
//            }
            if let data = data{
                
                var jsonLows = NSArray()
                
                do{
                    jsonLows = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                } catch let error as NSError {
                    print(error)
                    
                }

                var jsonLow = NSDictionary()
                for row in jsonLows{
                    jsonLow = row as! NSDictionary
                    let lowEvent = LowEventModel(time: jsonLow["Low_Start_Time"] as! String, isGC: (jsonLow["GC_or_not_GC"] as? Int ?? 0))
                    
                    self.lowEvents.add(lowEvent)
//                    print(lowEvent.description)
                }
                
            }
            
        }.resume()
        
        sem1.wait()
        for i in 0..<lowEvents.count {
            findRelevantPoints(index: i)
        }
    }
    
    func findRelevantPoints(index: Int){
        let timepoints = NSMutableArray()
        
        guard let urlSearch = URL(string: "http://192.168.64.2/gluconfidence/PriorLow_times.php") else{return}
        var request = URLRequest(url: urlSearch)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let paramString = "UserID=" + String(userid) + "&LowTime=" + (lowEvents[index] as! LowEventModel).time!
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let sem2 = DispatchSemaphore(value: 0)
        let session2 = URLSession.shared
        session2.dataTask(with: request) { (data, response, error) in
            defer { sem2.signal() }
//            if let response = response{
//                print(response)
//            }
            if let data = data{
                
                var jsonPoints = NSArray()
                
                do{
                    jsonPoints = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    
                } catch let error as NSError {
                    print(error)
                    
                }

                var jsonPoint = NSDictionary()
                for row in jsonPoints{
                    jsonPoint = row as! NSDictionary
                    let jsonPoint = TimestampModel(time: jsonPoint["systemTime"] as! String, value: (jsonPoint["value"] as! Int));
                    timepoints.add(jsonPoint)
//                    print(jsonPoint.description)
                }
                
            }
            
        }.resume()
        
        sem2.wait()
        if(index == 0){
            plotGraph(timeData: timepoints, index: index, chart: chart1)
        }else if(index == 1){
            plotGraph(timeData: timepoints, index: index, chart: chart2)
        }else{
            plotGraph(timeData: timepoints, index: index, chart: chart3)
        }
    }

    func plotGraph(timeData: NSMutableArray, index: Int, chart: LineChartView){
        

        let yMin = 40
        let yMax = 240
        let leftAxis = chart.leftAxis
        leftAxis.axisMinimum = Double(yMin)
        leftAxis.axisMaximum = Double(yMax)
        leftAxis.granularity = 40
        
        let rightAxis = chart.rightAxis
        rightAxis.enabled = false
        
        let xAxis = chart.xAxis
        xAxis.valueFormatter = TimeValueFormatter()
        
        let lowTime = (lowEvents[index] as! LowEventModel).time!
        let isGC = (lowEvents[index] as! LowEventModel).isGC!
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let lowDate = dateFormatter.date(from: lowTime)!
        
//        print(lowDate)
//        print(lowTime)
        
        // xminF can be easily changed
        xAxis.axisMinimum = lowDate.timeIntervalSince1970 - 900.0
        xAxis.axisMaximum = lowDate.timeIntervalSince1970 + 2700.0
        
        xAxis.labelPosition = .bottom
        xAxis.granularity = 600
  
        // remove gridlines and axis line
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        leftAxis.drawAxisLineEnabled = false
//        leftAxis.drawGridLinesEnabled = false
        leftAxis.gridLineDashLengths = [3.0,3.0]
        chart.legend.enabled = false
        
        chart1.setVisibleXRange(minXRange: 6 * 600, maxXRange: 6 * 600)
        
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        var dataEntries3: [ChartDataEntry] = []
        var dataEntries4: [ChartDataEntry] = []
        
        var lowValue = Double(yMin)
        
        var isAfter = 0;
        for i in 0..<timeData.count {
            
            let data = timeData[i] as! TimestampModel
            if(data.time! == lowTime && isAfter == 0){
                isAfter = 1
                let date = dateFormatter.date(from: data.time!)
                let dataEntry = ChartDataEntry(x: date!.timeIntervalSince1970, y: Double(data.value!))
                    dataEntries1.append(dataEntry)
                lowValue = Double(data.value!)
            }
            if(isAfter == 0){
                let date = dateFormatter.date(from: data.time!)
                let dataEntry = ChartDataEntry(x: date!.timeIntervalSince1970, y: Double(data.value!))
                    dataEntries1.append(dataEntry)
                
            }else{
                let date = dateFormatter.date(from: data.time!)
                let dataEntry = ChartDataEntry(x: date!.timeIntervalSince1970, y: Double(data.value!))
                    dataEntries2.append(dataEntry)
            }
        }
        if timeData.count > 0 {
            
            let indictTop = ChartDataEntry(x: lowDate.timeIntervalSince1970, y: Double(yMin))
                dataEntries3.append(indictTop)
            let indictBottom = ChartDataEntry(x: lowDate.timeIntervalSince1970, y: Double(yMax))
                dataEntries3.append(indictBottom)
            
            let indictLeft = ChartDataEntry(x: lowDate.timeIntervalSince1970 - 900.0, y: lowValue)
                dataEntries4.append(indictLeft)
            let indictRight = ChartDataEntry(x: lowDate.timeIntervalSince1970 + 2700.0, y: lowValue)
                dataEntries4.append(indictRight)
            
            let dataSet1 = LineChartDataSet(entries: dataEntries1, label: "Before Low")
            let dataSet2 = LineChartDataSet(entries: dataEntries2, label: "After Low")
            let dataSet3 = LineChartDataSet(entries: dataEntries3, label: "Vertical Indicator")
            let dataSet4 = LineChartDataSet(entries: dataEntries4, label: "Horizontal Indicator")

            dataSet1.mode = .cubicBezier
            dataSet1.drawValuesEnabled = false
            dataSet1.lineWidth = 2
            dataSet1.circleRadius = 5
            dataSet1.circleHoleRadius = 2
            dataSet1.drawValuesEnabled = false
            
            dataSet2.mode = .cubicBezier
            dataSet2.drawValuesEnabled = false
            dataSet2.lineWidth = 2
            dataSet2.setColor(.orange)
            dataSet2.setCircleColor(.orange)
            dataSet2.circleRadius = 5
            dataSet2.circleHoleRadius = 2
            dataSet2.drawValuesEnabled = false
            
            dataSet3.mode = .cubicBezier
            dataSet3.drawValuesEnabled = false
            dataSet3.lineWidth = 0.8
            dataSet3.setColor(.gray)
            dataSet3.drawValuesEnabled = false
            dataSet3.drawCirclesEnabled = false
            
            dataSet4.mode = .cubicBezier
            dataSet4.drawValuesEnabled = false
            dataSet4.lineWidth = 0.8
            dataSet4.setColor(.gray)
            dataSet4.drawValuesEnabled = false
            dataSet4.drawCirclesEnabled = false
            
            let data = LineChartData()
            data.addDataSet(dataSet1)
            data.addDataSet(dataSet2)
            data.addDataSet(dataSet3)
            data.addDataSet(dataSet4)
            chart.data = data
        }
        
        // change timeozne back to current so the string could be in current timezone and not UTC
        dateFormatter.timeZone = TimeZone.current
        var labelString = dateFormatter.string(from: lowDate)
        
        if(isGC == 0){
            labelString = "Not Gluconfidence " + labelString
        }else{
            labelString = "Gluconfidence " + labelString
        }
        if(index == 0){
            label1.text = labelString
            if(isGC == 0){
                label1.backgroundColor = .red
            }else{
                label1.backgroundColor = .blue
                label1.textColor = .white
            }
        }else if index == 1 {
            label2.text = labelString
            if(isGC == 0){
                label2.backgroundColor = .red
            }else{
                label2.backgroundColor = .blue
                label2.textColor = .white
            }
        }else{
            label3.text = labelString
            if(isGC == 0){
                label3.backgroundColor = .red
            }else{
                label3.backgroundColor = .blue
                label3.textColor = .white
            }
        }
    }
    
}
