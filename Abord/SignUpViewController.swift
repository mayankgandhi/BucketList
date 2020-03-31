//
//  SignUpViewController.swift
//  Abord
//
//  Created by Mayank on 31/03/20.
//  Copyright © 2020 Mayank. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var GenderSegmentedControl: UISegmentedControl!
    var alertController:UIAlertController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        // Do any additional setup after loading the view.
        self.signUpAlert()
    }
    
    @IBAction func completeSignUp(_ sender: Any) {
        let user = PFUser()
        
        user.username = usernameField.text
        user.password = passwordField.text
        user["fullname"] = fullNameTextField.text
        var gender:String?
        switch GenderSegmentedControl.selectedSegmentIndex {
        case 0:
             gender = "male"
        case 1:
             gender = "female"
        case 2:
             gender = "other"
        default:
             gender = "n/a"
        }
        user["gender"] = gender
        
        user.signUpInBackground { (success, error) in
            if success  {
                self.present(self.alertController, animated: true)
            }   else    {
                print(error?.localizedDescription)
            }
        }
    }
    
    func signUpAlert()  {
        alertController = UIAlertController(title: "Successfully Signed Up", message: "Welcome Abord! Please log in with the credentials to access the app!", preferredStyle: .alert)
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        
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
