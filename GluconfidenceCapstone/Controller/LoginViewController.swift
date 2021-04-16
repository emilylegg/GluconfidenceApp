//
//  LoginViewController.swift
//  GluconfidenceCapstone
//
//  Created by Gluco Team on 4/15/21.
//

import Foundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameEdit: UITextField!
    @IBOutlet weak var passwordEdit: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var forgotUser: UIButton!
    @IBOutlet weak var forgotPass: UIButton!
    @IBOutlet weak var createAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        login.layer.cornerRadius = 5
        
    }
    
    @IBAction func createAccountAtn(_ sender: Any) {
        performSegue(withIdentifier: "create_segue", sender: nil)
    }
}
