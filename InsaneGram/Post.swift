//
//  Post.swift
//  InsaneGram
//
//  Created by Marcus Tam on 3/7/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var author: String!
    var likes: Int!
    var pathToImage: String!
    var userID: String!
    var postID: String!

    var peopleWhoLike: [String] = [String]()
}
