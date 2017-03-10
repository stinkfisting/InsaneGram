//
//  SignUpVC.swift
//  InsaneGram
//
//  Created by Marcus Tam on 3/6/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPwField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage: FIRStorageReference!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self

        //This storage has ref on Firebase storage
        let storage = FIRStorage.storage().reference(forURL: "gs://insanegram-fef5b.appspot.com/")
        
        ref = FIRDatabase.database().reference()
        
        //UserStorage is storage plus the folder "users"
        userStorage = storage.child("users")
    }

    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confirmPwField.text != "" else {
            return
        }
        if passwordField.text == confirmPwField.text {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                if let user = user {
                    
                    //Set up Firebase's current user display name to be the name they entered in nameField
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    //Images will be stored with User's ID key on Firebase Storage
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, err) in
                        
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        //Get URL of image on Firebase's storage
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(er!.localizedDescription)
                            }
                            
                            if let url = url {
                                //Create User into Firebase Database
                                let userInfo: [String: Any] = ["uid": user.uid, "full name": self.nameField.text!,
                                                               "urlToImage": url.absoluteString]
                                //Assign user to Database in users folder (Create such folder if it doesn't exist
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                                
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                        
                        
                    })
                    uploadTask.resume()
                    
                }
                
            })
            
        } else {
            print("Password does not match")
        }
        
        
        
    }
}










