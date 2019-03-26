//
//  StartVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit

class StartVC: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    
    let userDefault = UserDefaults.standard
    
    override func loadView() {
        super.loadView()
        signInButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if userDefault.bool(forKey: "usersignedin") {
            performSegue(withIdentifier: "startToHome", sender: self)
        }
        
    }
    
    @IBAction func createAnAccountButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "startToRegister", sender: self)
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "startToSignIn", sender: self)
    }
    
    
    
}

