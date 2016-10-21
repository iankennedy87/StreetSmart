//
//  ViewController.swift
//  insightly
//
//  Created by Ian Kennedy on 12/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var streetImage: UIImageView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        //Add notifcation when Google SignIn is complete
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.segueToMain(notification:)), name: .signInSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.displayFailureAlert(notification:)), name: .signInFailure, object: nil)
    }
    
    
    @IBAction func signInClicked(_ sender: AnyObject) {
        signInButton.isEnabled = false
    }
    
    //Presents main screen after Google SignIn complete
    func segueToMain(notification: NSNotification) {
        let mainScreen = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(mainScreen, animated: true, completion: nil)
    }
    
    func displayFailureAlert(notification: NSNotification) {
        let alert = UIAlertController(title: "Google SignIn failed", message: "Check your network connection and try again", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

