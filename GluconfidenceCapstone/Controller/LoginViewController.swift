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
    
    @IBAction func createActionBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "createAccount_segue", sender: self)
        
    }
    
//    let login = NSMutableArray()
    
    let userDefaults = UserDefaults()
    
    func getLogin() -> Int{
        
        var user = NSDictionary();
        var isFail = 1;
        let userName = userNameEdit.text!
        let passWord = passwordEdit.text!
        let sem = DispatchSemaphore(value: 0)
        let url = URL(string: "http://192.168.64.2/gluconfidence/Gluconfidence_Login.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let paramString = "Username=" + String(userName) + "&Password=" + String(passWord)
        
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            defer { sem.signal() }
            
            if let data = data{
//                    let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                
                var loginResult = NSDictionary()
                
                do{
                    loginResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                } catch let error as NSError {
                    print(error)
                    
                }
                if(loginResult["error"] as! NSNumber == 0){
                    user = loginResult["user"] as! NSDictionary
                    isFail = 0
                }else{
                    print(loginResult["message"]!)
                }
            }
            
        }.resume()
        
        sem.wait()
        if(isFail == 0){
            userDefaults.setValue(user["UserID"] as! Int, forKey: "userid")
            userDefaults.setValue(user["FirstName"] as! String, forKey: "firstname")
        }
 //       print(userDefaults.value(forKey: "userid")!)
 //       print(userDefaults.value(forKey: "firstname")!)
        
        return isFail
    }

    @IBAction func loginActionBtn(_ sender: UIButton) {
        let isFail = getLogin()
        if(isFail == 0){
            print("Success")
//            performSegue(withIdentifier: "loginHome_segue", sender: self)
            
        }
    }
}

