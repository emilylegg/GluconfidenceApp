//
//  LoginViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 4/15/21.
//

import Foundation
import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameEdit: UITextField!
    @IBOutlet weak var passwordEdit: UITextField!
    //@IBOutlet weak var login: UIButton!
    @IBOutlet weak var forgotPass: UIButton!
    @IBOutlet weak var forgotUser: UIButton!
    
    let defaultValues = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        //login.layer.cornerRadius = 5
    }
    
    @IBAction func createActionBtn(_ sender: Any) {
        performSegue(withIdentifier: "create_segue", sender: nil)
    }
    
    let login = NSMutableArray()
    
    func getLogin(){
        let userId = 3
        let userName = userNameEdit.text!
        let passWord = passwordEdit.text!
        let sem = DispatchSemaphore(value: 0)
        //let userName = userNameEdit.text!
        //let passWord = passwordEdit.text!
        let url = URL(string: "http://54.87.84.120/gluconfidence/Gluconfidence_Login.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let paramString = "UserID=" + String(userId) + "Username=" + String(userName) + "Password=" + String(passWord)
        
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        //let sem = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            defer { sem.signal() }
            
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
                    self.login.add(jsonElement)
                }
                
            }
            
        }.resume()
        
        sem.wait()
    }

    @IBAction func loginActionBtn(_ sender: Any) {
        
       
            
    }
}

