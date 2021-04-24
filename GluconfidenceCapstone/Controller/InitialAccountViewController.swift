//
//  InitialAccountViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 4/15/21.
//

import Foundation
import iOSDropDown
import Alamofire

class InitialAccountViewController: UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var sexInput: DropDown!
    @IBOutlet weak var gluInput: UITextField!
    @IBOutlet weak var last: UITextField!
    @IBOutlet weak var activityInput: DropDown!
    @IBOutlet weak var dailyInput: DropDown!
    @IBOutlet weak var insulinInput: UITextField!
    @IBOutlet weak var medInput: DropDown!
    @IBOutlet weak var yearsInput: UITextField!
    @IBOutlet weak var typeInput: DropDown!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var zipcodeInput: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var chatInput: DropDown!
    @IBOutlet weak var refill: UINavigationItem!
    @IBOutlet weak var subscriptionInput: UITextField!
   // @IBOutlet weak var refill: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //submit.layer.cornerRadius = 5
        scrollView.contentSize = CGSize(width: 400, height: 1000)
        //submitActionBtn.layer.cornerRadius = 5
        
        medInput.optionArray = ["DPP-4 Inhibitor", "SGLT2 Inhibitor","Metforrmin", "None","Other"]
        typeInput.optionArray = ["1","2", "Prediabetic"]
        chatInput.optionArray = ["Yes please", "No thank you"]
        sexInput.optionArray = ["Male", "Female"]    //put in a "why am I seeing this"
        dailyInput.optionArray = ["1", "2", "3", "4", "5", "6+", "Pump/Podd"]
        activityInput.optionArray = ["No Activity", "2-3 times a week 20-30 min", "3+ times a week 30+ min", "5+ times a week 30+ min","6+ times a week"]
    
    }
    
    @IBAction func submitActionBtn(_ sender: Any) {
        
        let userId = 3
        guard let url = URL(string: "http://54.87.84.120/gluconfidence/Gluconfidence_Login.php")else{return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //let paramString = "UserID=" + 
        
        let parameters = [
            "Username":userInput.text!,
            "Password":passwordInput.text!,
            "FirstName":name.text!,
            "LastName":last.text!,
            "Email":emailInput.text!,
            "Zip_Code":zipcodeInput.text!,
            "Age":ageInput.text!,
            "Weight":weightInput.text!,
            "Years_with_Diabetes":yearsInput.text!,
            "Avg_Daily_Units_of_Insulin":insulinInput.text!,
            "Current_GC_Bottles":gluInput.text!,
            "Gender":sexInput.text!,
            "Diabetes_Type":typeInput.text!,
            "On_Oral_Medication":medInput.text!,
            "Daily_Injections":dailyInput.text!,
            "Activity_Level":activityInput.text!,
            "Join_GC_Chat_Group":chatInput.text!,
            "Subscri[tion":subscriptionInput.text!
               ]
        
        AF.request(url, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if let result = response.value {
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    
                    //displaying the message in label
//                    self.labelMessage.text = jsonData.value(forKey: "message") as! String?
                }
            }
    }
    
}
