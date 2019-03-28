//
//  NavigationVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit

class NavigationVC: UINavigationController {
    
    override func loadView() {
        super.loadView()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
}
