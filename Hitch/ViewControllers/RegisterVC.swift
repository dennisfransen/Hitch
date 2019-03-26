//
//  RegisterVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    
    let userDefault = UserDefaults.standard
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        signInUser(email: emailField.text!, password: passwordField.text!)
    }
    
    func createUser(email: String, password: String) {
        
        if password == repeatPasswordField.text && firstnameField.text != "" && lastnameField.text != "" {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    self.signInUser(email: email, password: password)
                    
                    // Check if any field is empty. if not, create user in firestore database.
                    guard let firstname = self.firstnameField.text, !firstname.isEmpty else { return }
                    guard let lastname = self.lastnameField.text, !lastname.isEmpty else { return }
                    guard let email = self.emailField.text, !email.isEmpty else { return }
                    
                    self.createUserInDatabase(firstName: firstname, lastName: lastname, email: email)
                    
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        } else {
            print("Wrong password in some field or empty username field")
        }
        
    }
    
    func signInUser(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                // Signed in
                print("User signed in")
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                
                self.performSegue(withIdentifier: "registerToHome", sender: self)
            } else if (error?._code == AuthErrorCode.userNotFound.rawValue) {
                self.createUser(email: email, password: password)
            } else {
                print(error as Any)
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func createUserInDatabase(firstName: String, lastName: String, email: String) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let userCredentials : [String: Any] = ["firstName": firstName,
                                               "lastName": lastName,
                                               "email": email,
                                               "bio": "This is where you type your bio..."]
        
        self.db.collection("users").document(userID).setData(userCredentials)
        
    }
}
