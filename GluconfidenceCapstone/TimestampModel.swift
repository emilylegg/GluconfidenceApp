//
//  TimestampModel.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 4/15/21.
//

import Foundation

class TimestampModel: NSObject{
    
    // attributes
    
    var time: String?
    var value: Int?
    
    override init(){
        
    }
    
    init(time: String, value: Int){
        self.time = time
        self.value = value
    }
    
    override var description: String{
        return "Time: \(time ?? ""), Value: \(value ?? 70)"
        
    }
}
