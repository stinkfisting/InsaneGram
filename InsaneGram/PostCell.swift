//
//  PostCell.swift
//  InsaneGram
//
//  Created by Marcus Tam on 3/7/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var unlikeBtn: UIButton!
    
    var postID: String!
    
    
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        self.likeBtn.isEnabled = false
        
        //Connect to Firebase, put a like in the post and insert user who liked it
        
        let ref = FIRDatabase.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let post = snapshot.value as? [String: AnyObject] {
                //Create dictionary of people who liked the post
                
                let updateLikes: [String: Any] = ["peopleWhoLike/\(keyToPost)": FIRAuth.auth()!.currentUser!.uid]
                
                //Update Values in FirDatabase
                
                ref.child("posts").child(self.postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    
                    if error == nil {
                        //If someone simultaneously likes the same post, get latest update for that
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                            if let properties = snap.value as? [String: AnyObject] {
                                //After we get properties of that post, and check how many people are inside 'peopleWhoLike"
                                
                                if let likes = properties["peopleWhoLike"] as? [String: AnyObject] {
                                    let count = likes.count
                                    self.likesLabel.text = "\(count) Likes"
                                    
                                    //Update values in Firebase
                                    let update = ["likes": count]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                    
                                    self.likeBtn.isHidden = true
                                    self.unlikeBtn.isHidden = false
                                    self.likeBtn.isEnabled = true
                                }
                            }
                        })
                    }
                })
            }
        })
        ref.removeAllObservers()
    }
    
    @IBAction func unlikePressed(_ sender: Any) {
        self.unlikeBtn.isEnabled = false
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let properties = snapshot.value as? [String: AnyObject] {
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String: AnyObject] {
                    //Find who the current user is in 'peopleWhoLike'
                    
                    for (id, person) in peopleWhoLike {
                        if person as? String == FIRAuth.auth()!.currentUser!.uid {
                            //Remove that user from 'peopleWhoLike'
                            
                            ref.child("posts").child(self.postID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                
                                if error == nil {
                                    //Get new values and update the likes count
                                    
                                    ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                                        
                                        if let prop = snap.value as? [String: AnyObject] {
                                            if let likes = prop["peopleWhoLike"] as? [String: AnyObject] {
                                                let count = likes.count
                                                self.likesLabel.text = "\(count) Likes"
                                                
                                                ref.child("posts").child(self.postID).updateChildValues(["likes": count])
                                            } else {
                                                self.likesLabel.text = "0 Likes"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes": 0])
                                            }
                                        }
                                    })
                                }
                            })
                            self.likeBtn.isHidden = false
                            self.unlikeBtn.isHidden = true
                            self.unlikeBtn.isEnabled = true
                            break //Break out of loop after we found current user
                        }
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
}












