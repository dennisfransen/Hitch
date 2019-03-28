//
//  ImageHandler.swift
//  Hitch
//
//  Created by Dennis Fransen on 2019-03-28.
//  Copyright © 2019 Dennis Fransen. All rights reserved.
//

import UIKit
import Firebase

extension SettingsVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
            uploadImageToFirestore()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func uploadImageToFirestore() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = storage.reference().child("usersProfileImages/\(uid).png")
        
        let uploadData = profileImage.image
        if let imageData = uploadData?.pngData() {
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error!)
                } else {
                    print(metadata!)
                }
            }
        }
        
        // Set the new image as the value of the image in AppDelegate so the profile image matches the one that was just uploaded
        self.appDelegate.userProfileImage = uploadData
        
    }
    
    
}
