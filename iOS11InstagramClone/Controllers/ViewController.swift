//
//  ViewController.swift
//  iOS11InstagramClone
//
//  Created by Kenneth Nagata on 5/25/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameScore = PFObject(className:"GameScore")
        gameScore["score"] = 1337
        gameScore["playerName"] = "Sean Plott"
        gameScore["cheatMode"] = false
        gameScore.saveInBackground {
            (success: Bool, error: Error?) in
            if (success) {
                // The object has been saved.
                print("Success")
            } else {
                // There was a problem, check error.description
                print("Failed")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

