//
//  ViewController.swift
//  iOS11InstagramClone
//
//  Created by Kenneth Nagata on 5/25/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    var signUpModeActive = true
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var switchLogInModeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signUp () {
        let user = PFUser()
        var validPass = false
        var validEmail = false
        
        if let email = emailTextfield.text{
            if(isValidEmail(testStr: email)){
                validEmail = true
                user.email = email
                user.username = email
            }  else {
                self.displayAlert(title: "Email Error", message: "Please enter a valid email")
            }
        }
        
        if let pass = passwordTextField.text {
            if(isValidPassword(testStr: pass)){
                validPass = true
                user.password = pass
            }  else {
                self.displayAlert(title: "Password Error", message: "Please enter a valid pasword")
            }
        }
        
        if validPass && validEmail {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()

            if(signUpModeActive) {
                user.signUpInBackground { (success, error) in
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if success{
                        print("Sucessfully singed up.")
                    } else {
                       self.displayAlert(title: "Error signing up", message: error?.localizedDescription ?? "Error")
                    }
                }
            } else {
                PFUser.logInWithUsername(inBackground: user.email!, password: user.password!) { (user, error) in
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()    
                    if(user != nil){
                        print("log in successful")
                    } else {
                        self.displayAlert(title: "Error logging in", message: error?.localizedDescription ?? "Error, please try again")
                    }
                }
            }
        }
    }

    // check if email has valid format xxx@.yyy
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // Check password for at least 1 uppercase, 1 special, 2 digits, 3 lowercase, 8 lenght
    func isValidPassword(testStr:String) -> Bool {
        let passRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}$"
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: testStr)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    


    @IBAction func signUpOrLogin(_ sender: UIButton) {
        signUp()
        
    }
    
    @IBAction func switchLogInMode(_ sender: UIButton) {
        if(signUpModeActive){
            signUpModeActive = false
            signUpButton.setTitle("Log In", for: [])
            switchLogInModeButton.setTitle("Sign Up", for: [])
        } else {
            signUpModeActive = true
            signUpButton.setTitle("Sign Up", for: [])
            switchLogInModeButton.setTitle("Log In", for: [])
        }
    }
    
}

