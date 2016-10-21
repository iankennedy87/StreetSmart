//
//  OrgTableViewController.swift
//  insightly
//
//  Created by Ian Kennedy on 13/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

@available(iOS 10.0, *)
class OrgTableViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    let del = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
        // Step 2: invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
        
        let backgroundImage = #imageLiteral(resourceName: "streetsmart")
        self.tableView.backgroundView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView?.alpha = 0.15
        self.tableView.backgroundView?.contentMode = .scaleAspectFit
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //moves activity indicator to center of screen
        activityIndicator.frame = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2, width: 10, height: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let orgs = fetchedResultsController.fetchedObjects as! [Organisation]
        InsightlyClient.sharedInstance.downloadInsightlyImages(orgs: orgs, completionHandler: nil)
    }
    
   
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
   
    //Deletes all organisation from CoreData and downloads again from website
    func refresh() {
        InsightlyClient.sharedInstance.downloadInsightlyCustomers(viewController: self, fetchedResultsController: fetchedResultsController, uiUpdates: toggleActivityIndicator, completionHandler: {
            
            self.del.saveContext()
            
            DispatchQueue.main.async {
                let orgs = self.fetchedResultsController.fetchedObjects as! [Organisation]
                InsightlyClient.sharedInstance.downloadInsightlyImages(orgs: orgs, completionHandler: nil)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "OrgCell"
        
        let org = fetchedResultsController.object(at: indexPath) as! Organisation
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)!
        
        cell.textLabel!.text = org.name
        cell.textLabel!.textColor = UIColor.getCustomTextColor()
        cell.textLabel?.font = UIFont(name: "Futura", size: 17.0)
            configureCell(cell: cell, org: org)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let org = fetchedResultsController.object(at: indexPath) as! Organisation
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "OrgOverviewController") as! OrgOverviewController
        
        controller.org = org
        
        //checks if organisation has been accessed before and notifies next view controller to prevent repeated downloads
        if org.geocodeComplete {
            controller.firstView = false
        }
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        switch (editingStyle) {
        case .delete:
            
            //Delete organisation from core data and remove from table view
            let org = fetchedResultsController.object(at: indexPath) as! Organisation
            org.image = nil
            context.delete(org)
            del.saveContext()
            
        default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            //Redraws cell in case of update e.g. image downloaded
            if let cell = tableView.cellForRow(at: indexPath!) {
            let org = controller.object(at: indexPath!) as! Organisation
            configureCell(cell: cell, org: org)
            }
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    //Sets table view cell to a placeholder while images download
    func configureCell(cell: UITableViewCell, org: Organisation) {
        let placeholderImage = #imageLiteral(resourceName: "placeholder")
        
        cell.imageView?.image = nil
        
        //If photo already has an image assigned, make it the cell image
        if let localImage = org.image {
            cell.imageView?.image = UIImage(data: localImage as Data)
        } else {
            //if not, set the cell image to the placeholder while the image downloads
            cell.imageView?.image = placeholderImage
            
        }
        
    }
    
    func toggleActivityIndicator() -> Void {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}
