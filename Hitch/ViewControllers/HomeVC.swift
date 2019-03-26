//
//  HomeVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
    }
    
    @IBAction func sidemenuButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "homeToSidemenu", sender: self)
    }
}
