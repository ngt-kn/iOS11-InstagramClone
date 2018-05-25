//
//  UserTableViewController.swift
//  iOS11InstagramClone
//
//  Created by Kenneth Nagata on 5/25/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {

    var usernames = [""]
    var objectIDs = [""]
    var isFollowing = ["" : false]
    
    var pullToRefresh: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTable()

        pullToRefresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        pullToRefresh.addTarget(self, action: #selector(UserTableViewController.loadTable), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(pullToRefresh)

    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTableCell", for: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        if let follows = isFollowing[objectIDs[indexPath.row]]{
            if  follows {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let follows = isFollowing[objectIDs[indexPath.row]]{
            if  follows {
                
                isFollowing[objectIDs[indexPath.row]] = false
                cell?.accessoryType = UITableViewCellAccessoryType.none
                
                let query = PFQuery(className: "Following")
                
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIDs[indexPath.row])
                
                query.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            } else {
                isFollowing[objectIDs[indexPath.row]] = true
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
                let following = PFObject(className: "Following")
                
                following["follower"] = PFUser.current()?.objectId
                
                following["following"] = objectIDs[indexPath.row]
                
                following.saveInBackground()
                
            }
        }
    }
    
    @objc func loadTable(){
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        query?.findObjectsInBackground(block: { (users, error) in
            
            if error != nil {
                print(error)
            } else if let users = users {
                
                self.usernames.removeAll()
                self.objectIDs.removeAll()
                self.isFollowing.removeAll()
                
                for object in users {
                    if let user = object as? PFUser {
                        if let username = user.username{
                            if let objectID = user.objectId{
                                let usernameArray = username.components(separatedBy: "@")
                                
                                self.usernames.append(usernameArray[0])
                                self.objectIDs.append(objectID)
                                
                                let query = PFQuery(className: "Following")
                                
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                                query.whereKey("following", equalTo: objectID)
                                
                                query.findObjectsInBackground(block: { (objects, error) in
                                    if let objects = objects {
                                        if objects.count > 0 {
                                            self.isFollowing[objectID] = true
                                        } else {
                                            self.isFollowing[objectID] = false
                                        }
                                        
                                        if self.usernames.count == self.isFollowing.count{
                                            
                                            self.tableView.reloadData()
                                            
                                            self.pullToRefresh.endRefreshing()
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                
            }
        })
    }
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        performSegue(withIdentifier: "logOutSegue", sender: self)
    }
    
    


}
