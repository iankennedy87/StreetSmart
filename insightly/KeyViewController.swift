//
//  KeyViewController.swift
//  insightly
//
//  Created by Ian Kennedy on 13/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import Foundation
import UIKit

class KeyViewController : UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var apiTextField: UITextField!
    
    @IBOutlet weak var infoLink: UIButton!
    
    var oldKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiTextField.delegate = self
        
        //Rounded corners on buttons
        infoLink.layer.cornerRadius = 5
        submitButton.layer.cornerRadius = 5
        
        //If API Key already stored, display in text field
        if let apiKey = UserDefaults.standard.value(forKey: UserDefaultKeys.apiKey) as? String {
            apiTextField.text = apiKey
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        apiTextField.resignFirstResponder()
        return true
    }
    
    //Saves current key in variable for comparison after editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        oldKey = apiTextField.text
    }
    
    
    @IBAction func submitClicked(_ sender: AnyObject) {
        oldKey = UserDefaults.standard.value(forKey: UserDefaultKeys.apiKey) as! String?
        //Only resets api key and download bool if api key has changed
        if apiTextField.text != oldKey {
            print("Key changed")
            UserDefaults.standard.set(apiTextField.text, forKey: UserDefaultKeys.apiKey)
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.customersDownloaded)
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.hasKey)
        }
        
        NotificationCenter.default.post(name: .keyAdded, object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
   
    //Takes user to Insightly website with info on where to find API Key
    @IBAction func infoLinkClicked(_ sender: AnyObject) {
        UIApplication.shared.open(InsightlyClient.Constants.infoLink)
    }
    
}
