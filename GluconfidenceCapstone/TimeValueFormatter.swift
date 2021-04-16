//
//  TimeValueFormatter.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 4/15/21.
//

import Foundation
import Charts

public class TimeValueFormatter: NSObject, IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let date = Date(timeIntervalSince1970: value)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(for: date) ?? ""
    }
}
