//
//  LowEventModel.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 4/18/21.
//

import Foundation

class LowEventModel: NSObject{
    
    // attributes
    
    var time: String?
    var isGC: Int?
    
    override init(){
        
    }
    
    init(time: String, isGC: Int){
        self.time = time
        self.isGC = isGC
    }
    
    override var description: String{
        return "Time: \(time ?? ""), Value: \(isGC ?? 70)"
        
    }
}
