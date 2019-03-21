//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    //MARK: Set up a new user on our Firbase database
  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        //paduodam du itemus: email ir psw ir kai metodas ivyksta (completed) mums pagrazina irgi du itemus: user ir error
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            
            //kodas apacioje veiks tik tada kai ivyks firebase authentication procesas
            (user, error) in
            if error != nil {
                print(error!)
            } else {
                //success
                print("Registration sucessfull")
                SVProgressHUD.dismiss()
                //if we want to call a method inside closure we need to write self before it
                self.performSegue(withIdentifier: "goToChat", sender: self)
                                
            }
        }
        
    } 

}
