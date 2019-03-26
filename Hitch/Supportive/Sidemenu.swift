//
//  Sidemenu.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import Firebase
import SideMenu

let myCell = "sidemenuCell"

class Sidemenu: UITableViewController {
    
    let userDefault = UserDefaults.standard
    let sidemenuChoice: [String] = ["Profile", "About", "Contact", "Settings", "Sign out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.default.menuPresentMode = .menuDissolveIn

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sidemenuChoice.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: myCell , for: indexPath) as! SidemenuCell
        
        cell.titleField.text = sidemenuChoice[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var viewController: UIViewController = UIViewController()
        
        switch (indexPath.row) {
        case 0:
            viewController = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! ProfileVC
        case 1: break
//            viewController = self.storyboard?.instantiateViewController(withIdentifier: "contact") as! ContactVC
        case 2: break
//            viewController = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsVC
        case 4:
            do {
                try Auth.auth().signOut()
                userDefault.removeObject(forKey: "usersignedin")
                userDefault.synchronize()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
//            viewController = self.storyboard?.instantiateViewController(withIdentifier: "start") as! StartVC
            performSegue(withIdentifier: "signoutSegue", sender: self)
            return
        default:
            print("default")
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
