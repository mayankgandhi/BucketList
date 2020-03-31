//
//  LoginViewController.swift
//  Abord
//
//  Created by Mayank on 30/03/20.
//  Copyright © 2020 Mayank. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginCustomButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        loginCustomButton.shake()
        let username = emailField.text!
        let password  = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username , password: password) { (user, error) in
            if (error != nil) {
                print(error?.localizedDescription)
                
            }   else    {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        
    }
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = emailField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success  {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }   else    {
                print(error?.localizedDescription)
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
