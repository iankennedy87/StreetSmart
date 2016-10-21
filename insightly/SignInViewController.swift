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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        GIDSignIn.sharedInstance().uiDelegate = self
        //Add notifcation when Google SignIn is complete
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.segueToMain(notification:)), name: .signInSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.displayFailureAlert(notification:)), name: .signInFailure, object: nil)
    }

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            signInButton.isEnabled = false
            activityIndicator.startAnimating()
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    @IBAction func signInClicked(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        signInButton.isEnabled = false
    }
    
    //Presents main screen after Google SignIn complete
    func segueToMain(notification: NSNotification) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.signInButton.isEnabled = true
        let mainScreen = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(mainScreen, animated: true, completion: nil)
        }
    }
    
    func displayFailureAlert(notification: NSNotification) {
        signInButton.isEnabled = true
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Google SignIn failed", message: "Check your network connection and try again", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

