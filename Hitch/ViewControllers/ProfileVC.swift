//
//  ProfileVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullNameField: UILabel!
    @IBOutlet weak var cityField: UILabel!
    @IBOutlet weak var bioField: UITextView!
    
    let userDefault = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    var panGesture = UIPanGestureRecognizer()
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayDownOffset = 150
        trayUp = profileView.center
        trayDown = CGPoint(x: profileView.center.x, y: profileView.center.y - trayDownOffset)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    @IBAction func panUp(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)

        if sender.state == UIGestureRecognizer.State.began {
            trayOriginalCenter = profileView.center
        } else if sender.state == UIGestureRecognizer.State.changed {
            profileView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == UIGestureRecognizer.State.ended {
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.profileView.center = self.trayUp
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.profileView.center = self.trayDown
                }
            }
        }
        
    }
 
    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "profileToEditProfile", sender: self)
    }
    
    func setupView() {
        profileImage.image = appDelegate.userProfileImage
        fullNameField.text = appDelegate.fullNameOfUser
        bioField.text = appDelegate.bioOfUser
        cityField.text = appDelegate.cityStateOfUser

    }
}
