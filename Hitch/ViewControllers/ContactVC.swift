//
//  ContactVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-28.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit

class ContactVC: UIViewController {
    
    @IBOutlet weak var contactView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactView.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }
}
