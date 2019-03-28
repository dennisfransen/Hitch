//
//  SettingsVC.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-26.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import Firebase


class SettingsVC: UIViewController {
    
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var cityStateField: UITextField!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileView: UIView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
//    var trayOriginalCenter: CGPoint!
//    var trayDownOffset: CGFloat!
//    var trayUp: CGPoint!
//    var trayDown: CGPoint!
    
    override func loadView() {
        super.loadView()
        profileImage.image = appDelegate.userProfileImage
        fullNameField.text = appDelegate.fullNameOfUser
        bioField.text = appDelegate.bioOfUser
        cityStateField.text = appDelegate.cityStateOfUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        trayDownOffset = 400
//        trayUp = profileView.center
//        trayDown = CGPoint(x: profileView.center.x, y: profileView.center.y - trayDownOffset)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @IBAction func presentImageLibrary(_ sender: UITapGestureRecognizer) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        print("TAP TAP TAP")
    }
    
//    @IBAction func panUp(_ sender: UIPanGestureRecognizer) {
//        
//        let translation = sender.translation(in: view)
//        let velocity = sender.velocity(in: view)
//        
//        if sender.state == UIGestureRecognizer.State.began {
//            trayOriginalCenter = profileView.center
//        } else if sender.state == UIGestureRecognizer.State.changed {
//            profileView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
//        } else if sender.state == UIGestureRecognizer.State.ended {
//            if velocity.y > 0 {
//                UIView.animate(withDuration: 0.3) {
//                    self.profileView.center = self.trayUp
//                }
//            } else {
//                UIView.animate(withDuration: 0.3) {
//                    self.profileView.center = self.trayDown
//                }
//            }
//        }
//    }
    
    @IBAction func saveSettingsPressed(_ sender: UIButton) {
        saveChangedDataToDatabase(fullName: fullNameField.text!, bio: bioField.text!, cityState: cityStateField.text!)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func saveChangedDataToDatabase(fullName: String, bio: String, cityState: String) {
        
        checkBioFieldContent(content: "", outputContent: "Type your bio here...")
 
        guard let currentUser = Auth.auth().currentUser else { return }
        let userID = currentUser.uid
        
        let userCredentials : [String: Any] = ["fullName": fullName,
                                               "cityState": cityState,
                                               "bio": bio]
        
        self.appDelegate.fullNameOfUser = fullName
        self.appDelegate.cityStateOfUser = cityState
        self.appDelegate.bioOfUser = bio
        
        db.collection("users").document(userID).updateData(userCredentials)
    }
    
    func checkBioFieldContent(content: String, outputContent: String) {
        if bioField.text == content {
            bioField.text = outputContent
        }
  
    }
    
}
