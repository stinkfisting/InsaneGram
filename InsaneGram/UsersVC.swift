//
//  UsersVC.swift
//  InsaneGram
//
//  Created by Marcus Tam on 3/6/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import Firebase

class UsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var user = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveUsers()
    }
    
    func retrieveUsers() {
        let ref = FIRDatabase.database().reference()
        
        //Give me snapshot of all the values into 'users' folder ordered by Key
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let users = snapshot.value as! [String: AnyObject]
            self.user.removeAll()
            //Loop through all values in users Dictionary
            for (_, value) in users {
                
                //Get all UserIDs, check if they are equal to current UserID, and not to include current, but all others
                if let uid = value["uid"] as? String {
                    
                    //if uid does not equal current user ID, add to user Array
                    if uid != FIRAuth.auth()!.currentUser!.uid {
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullName
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            self.user.append(userToShow)
                        }
                        
                    }
                    
                }
            }
            self.tableView.reloadData()
        })
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.nameLabel.text = self.user[indexPath.row].fullName
        cell.userID = self.user[indexPath.row].userID
        cell.userImage.downloadImage(from: self.user[indexPath.row].imagePath)
        
        checkFollowing(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //For every row that we are selecting, check if current user is following that user or not
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key    //Get string "Key" so we can add all user's following/followers
        
        //Check if current user is a follower of selected user
        var isFollower = false
        
        ref.child("users").child(uid).child("following").observeSingleEvent(of: .value, with: { (snapshot) in
            //Unfollow user

            if let following = snapshot.value as? [String: AnyObject] {
                for (ke, value) in following {
                    //If value == user selected, that means the current user is following this user
                    
                    if value as! String == self.user[indexPath.row].userID {
                        isFollower = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        
                        //Go to selected user and remove a follower(the current user)
                        ref.child("users").child(self.user[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        //Specify that cell does not have checkmark
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            //Follow user
            if !isFollower {
                let following = ["following/\(key)": self.user[indexPath.row].userID] //selected user
                let followers = ["followers/\(key)" : uid] //current user
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.user[indexPath.row].userID).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        ref.removeAllObservers()
    }

    
    func checkFollowing(indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").observeSingleEvent(of: .value, with: { (snapshot) in

            if let following = snapshot.value as? [String: AnyObject] {
                for (_, value) in following {
                    if value as! String == self.user[indexPath.row].userID {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
  
    @IBAction func logOutPressed(_ sender: Any) {

        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        
        self.present(loginVC, animated: true, completion: nil)
        //        let alert = UIAlertController(title: "Are you sure you want to Log Out?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        //
        //        //Add the actions(buttons)
        //        alert.addAction(UIAlertAction(title: "Log Out", style: UIAlertActionStyle.destructive, handler: { (action) in
        //
        //            //Check if there is a user signed in
        //            if FIRAuth.auth()!.currentUser != nil {
        //
        //                do {
        //                    try? FIRAuth.auth()!.signOut()
        //
        //                    if FIRAuth.auth()?.currentUser == nil {
        //                        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        //                        self.present(loginVC, animated: true, completion: nil)
        //                    }
        //                }
        //            }}))
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //        
        //        self.present(alert, animated: true, completion: nil)
    }

    
    
}

//Create extension to instantly download image by passing in imagepath and the image will appear

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        //Create URL session where it will download the image and update
        
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            //Dispatch a main queue because URLSession goes into our background, might cause crash
            DispatchQueue.main.async {
                //Set image in main Queue
                self.image = UIImage(data: data!) //self.image is image of imageView
            }
        }
        task.resume()
    }
}











