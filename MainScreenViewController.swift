//
//  MainScreenViewController.swift
//  insightly
//
//  Created by Ian Kennedy on 13/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainScreenViewController: UIViewController {
    
    @IBOutlet weak var viewCustomersButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var setKeyButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let del = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        if (del.user == nil) {
            do {
                try userFetchedResultsController.performFetch()
            } catch {}
            
            print("count \(userFetchedResultsController.fetchedObjects!.count)")
            
            guard (userFetchedResultsController.fetchedObjects!.count > 0) else {
                let currentUser = GIDSignIn.sharedInstance().currentUser!
                del.user = User(userId: currentUser.userID, email: currentUser.profile.email, context: context)
                del.saveContext()
                print("User created")
                return
            }
            
            if let user = userFetchedResultsController.fetchedObjects![0] as? User {
                del.user = user
                print("del.user added")
            }
            
        }
        
        navigationItem.title = del.user!.email
    }
    
    lazy var userFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "userId", ascending: true)]
        
        let currentUser = GIDSignIn.sharedInstance().currentUser.userID!
        
        print("Current user id \(currentUser)")
        
        fetchRequest.predicate = NSPredicate(format: "userId = %@", argumentArray: [currentUser])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
        
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = Organisation.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let user = self.del.user!
        
        fetchRequest.predicate = NSPredicate(format: "user = %@", argumentArray: [user])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
        
    }()
   
    //Sign out of Google and return to main screen
    @IBAction func googleSignOout(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        del.user = nil
        self.dismiss(animated: true, completion: nil)
    }

    //Present view controller to set API Key
    @IBAction func setKey(_ sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "KeyViewController") as! KeyViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //If data hasn't been downloaded for current API Key, downloads and presents organisation table view. 
    @IBAction func getInsightlyData(_ sender: AnyObject) {
        //Presents an alert if an API key hasn't been entered
//        if !UserDefaults.standard.bool(forKey: UserDefaultKeys.hasKey) {
        if !del.user!.hasKey {
            let alert = UIAlertController(title: "No API Key", message: "You must add an Insightly API Key before viewing customers", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Add an API Key", style: .default, handler: { (action) in
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "KeyViewController") as! KeyViewController
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            //If data hasn't been downloaded with current API key, does so now
//        } else if !UserDefaults.standard.bool(forKey: UserDefaultKeys.customersDownloaded) {
        } else if !del.user!.customersDownloaded {
        
            InsightlyClient.sharedInstance.downloadInsightlyCustomers(viewController: self, fetchedResultsController: fetchedResultsController, uiUpdates: toggleButtons, completionHandler: {
                
//                UserDefaults.standard.set(true, forKey: UserDefaultKeys.customersDownloaded)
                self.del.user!.customersDownloaded = true
                self.del.saveContext()
                DispatchQueue.main.async {
                    let orgTableView = self.storyboard!.instantiateViewController(withIdentifier: "OrgTableViewController") as! OrgTableViewController
                    self.navigationController?.pushViewController(orgTableView, animated: true)
                }
            })
            
        } else {
            let orgTableView = self.storyboard!.instantiateViewController(withIdentifier: "OrgTableViewController") as! OrgTableViewController
            self.navigationController?.pushViewController(orgTableView, animated: true)
        }
    }
    
    //Present "About" view controller
    @IBAction func aboutStreetSmart(_ sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "AboutViewController")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //Toggles buttons and activity indicator during downloads
    func toggleButtons() -> Void {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        
        viewCustomersButton.isEnabled = !viewCustomersButton.isEnabled
        setKeyButton.isEnabled = !setKeyButton.isEnabled
    }
}
