//
//  FeedTableViewController.swift
//  iOS11InstagramClone
//
//  Created by Kenneth Nagata on 5/25/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    
    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            if let users = objects {
                
                for object in users {
                    if let user = object as? PFUser {
                        //TODO: - safe unwrap
                        self.users[user.objectId!] = user.username!
                    }
                }
            }
            
            let getFollowedUserQuery = PFQuery(className: "Following")
            
            getFollowedUserQuery.whereKey("follower", equalTo: PFUser.current()?.objectId)
            
            getFollowedUserQuery.findObjectsInBackground(block: { (objects, error) in
                if let follwers = objects {
                    for follower in follwers {
                        if let followedUser = follower["following"] {
                            let query = PFQuery(className: "Post")
                            query.whereKey("userid", equalTo: followedUser)
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let posts = objects {
                                    for post in posts {
                                        //TODO: - If let for safe unwrap
                                        self.comments.append(post["message"] as! String)
                                        self.usernames.append(self.users[post["userid"] as! String]!)
                                        self.imageFiles.append(post["imageFile"] as! PFFile)
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                            })
                        }
                    }
                }
            })
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedTableViewCell

        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let image = data {
                if let imageToDisplay = UIImage(data: image) {
                    cell.postedImage.image = imageToDisplay
                }
            }
        }
        
        cell.comment.text = comments[indexPath.row]
        
        cell.userInfo.text = usernames[indexPath.row]
        
        self.tableView.rowHeight = cell.postedImage.bounds.size.height + cell.userInfo.bounds.size.height + cell.comment.bounds.size.height + 50
        
        return cell
    }

}
