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
    @IBOutlet weak var firstnameField: UILabel!
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
        retriveUserProfileImageFromFirebaseStorage()
        retriveNameAndBioFromFirebaseDatabase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trayDownOffset = 150
        trayUp = profileView.center
        trayDown = CGPoint(x: profileView.center.x, y: profileView.center.y - trayDownOffset)
        
        
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
    
    func retriveNameAndBioFromFirebaseDatabase() {
        
        let db = Firestore.firestore()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let docRef = db.collection("users").document(userID)
        docRef.getDocument { (DocumentSnapshot, error) in
            if let _ = error {
                print("Error")
            } else {
                let firstName = DocumentSnapshot!.get("firstName") as! String
                let lastName = DocumentSnapshot!.get("lastName") as! String
                let bio = DocumentSnapshot!.get("bio") as! String
                
                self.firstnameField.text = "\(firstName) \(lastName)"
                self.bioField.text = bio
                
//                self.appDelegate.firstnameOfUser = firstname
//                self.appDelegate.lastnameOfUser = lastname
//                self.appDelegate.fullNameOfUser = "\(firstName) \(lastName)"
//                self.appDelegate.bioOfUser = bio
            }
        }
        
    }
    
    func retriveUserProfileImageFromFirebaseStorage() {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "usersProfileImages/\(userID).png")
        
        pathReference.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                let image = #imageLiteral(resourceName: "Background Register")
                self.profileImage.image = image
//                self.appDelegate.userProfileImage = image
                print(error.localizedDescription)
            } else {
                self.profileImage.image = UIImage(data: data!)!
//                self.appDelegate.userProfileImage = UIImage(data: data!)!
            }
        }
        
    }
}
