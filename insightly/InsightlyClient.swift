//
//  InsightlyClient.swift
//  insightly
//
//  Created by Ian Kennedy on 13/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class InsightlyClient : NSObject {
    
    let session = URLSession.shared
    let del = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    typealias getJSONCompletionHandler = (_ result: [[String:AnyObject]]?, _ alert: UIAlertController?) -> Void
    
    //Accesses insightly API and returns JSON
    func insightlyGetJSONRequest(endpoint ep: String, params: [String: AnyObject], completionHandler: @escaping getJSONCompletionHandler) -> Void {
        
        let apiKey = UserDefaults.standard.value(forKey: UserDefaultKeys.apiKey) as! String
        let apiKey64Encoded = apiKey.data(using: String.Encoding.utf8)!.base64EncodedString()
        
        let url = insightlyURLFromParameters(ep, parameters: params)
        print("url \(url)")
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("Basic \(apiKey64Encoded)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            func displayError(_ error: NSError) {
                print("There was an error with your request: \(error)")
            }
            
            guard (error == nil) else {
                displayError(error! as NSError)
                let alert = UIAlertController(title: "Download failed", message: "Encountered an error while attempting to download from insightly.com. Check your network connection and try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                completionHandler(nil, alert)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode  , statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx! \(response)")
                let alert = UIAlertController(title: "Download failed", message: "Failed to download customers from insightly.com. Check your network connection and API key.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                completionHandler(nil, alert)
                return
            }
            
            guard let data = data else {
                print("No data was returned")
                let alert = UIAlertController(title: "No data returned", message: "No date was returned while attempting to download from insightly.com. Ensure that you have saved organisations.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                completionHandler(nil, alert)
                return
            }
            
            let parsedResult: [[String:AnyObject]]
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:AnyObject]]
            } catch {
                print("Could not parse data as JSON: \(data)")
                return
            }
            
            print("Parsed result: \(parsedResult)")
            completionHandler(parsedResult, nil)
            
        })
        
        task.resume()
    }
    
    //Downloads all organisations from insightly and creates CoreData objects with addreses. Takes a UIUpdate closure to perform UI updates on the view controller
    func downloadInsightlyCustomers(viewController: UIViewController, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, uiUpdates: @escaping (()->Void), completionHandler: @escaping (()->Void)) -> Void {
        
        DispatchQueue.main.async {
            uiUpdates()
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        let orgs = fetchedResultsController.fetchedObjects as! [Organisation]
        
        for org in orgs {
            context.delete(org)
        }
        
        let params = ["brief":"false", "count_total": "false"]
        
        InsightlyClient.sharedInstance().insightlyGetJSONRequest(endpoint: API.OrganisationEndpoint, params: params as [String: AnyObject]) { (result, alert) in
            
            //Display an alert if an error occurs
            guard (alert == nil) else {
                DispatchQueue.main.async {
                    uiUpdates()
                    viewController.present(alert!, animated: true, completion: nil)
                }
                return
            }
            
            for org in result! {
                let name = org[ResponseKeys.name] as! String
                let url = org[ResponseKeys.imageUrl] as! String?
                let addresses = org[ResponseKeys.addresses] as! [[String:AnyObject]]
                let addressDict = addresses[0]
                
                let address = InsightlyClient.sharedInstance().convertInsightlyAddressToString(addressDict)
                let _ = Organisation(name: name, address: address.addressString, addressByLine: address.addressByLine, imageUrl: url, context: self.context)
            }
            
            DispatchQueue.main.async {
                uiUpdates()
            }
           
            completionHandler()
            
        }
    }
    
    //Helper function for downloading images
    func taskForDownloadImage(url: String, completionHandler: @escaping (_ imageData: NSData?, _ error: NSError?) -> Void) -> Void  {
        
        let imageUrl = NSURL(string: url)
        
        let request = URLRequest(url: imageUrl! as URL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let newError = error {
                print(error)
                completionHandler(nil, newError as NSError?)
            } else {
                completionHandler(data as NSData?, nil)
            }
        }
        
        task.resume()
        
    }
    
    //Checks if organisations already have images saved to disk and downloads if not
    func downloadInsightlyImages(orgs: [Organisation], completionHandler: ((_ success: Bool) -> Void)?) -> Void {
        for org in orgs {
            if org.image == nil && org.imageUrl != nil {
                print("image url \(org.imageUrl)")
                taskForDownloadImage(url: org.imageUrl!, completionHandler: { (data, error) in
                    if let imageData = data {
                        DispatchQueue.main.async {
                            org.image = imageData
                            self.del.saveContext()
                        }
                    }
                })
            }
        }
    }
    
    class func sharedInstance() -> InsightlyClient {
        struct Singleton {
            static var sharedInstance = InsightlyClient()
        }
        return Singleton.sharedInstance
    }
    
    //Returns a two element tuple: first, and address string for geocoding and an address with elements separated by line for display
    func convertInsightlyAddressToString(_ insightlyAddress: [String: AnyObject]) -> (addressString: String, addressByLine: String) {
        
        var addressString = ""
        var street: String = ""
        var city: String = ""
        var state: String = ""
        var postcode: String = ""
        var country: String = ""
        
        if let s = insightlyAddress[ResponseKeys.street] as? String {
            street = s
        }
        
        if let c = insightlyAddress[ResponseKeys.city] as? String {
            city = c
        }
        
        if let st = insightlyAddress[ResponseKeys.state] as? String {
            state = st
        }
        
        if let p = insightlyAddress[ResponseKeys.postcode] as? String {
            postcode = p
        }
        
        if let co = insightlyAddress[ResponseKeys.country] as? String {
            country = co
        }
        
        addressString = "\(street) \(city) \(state) \(postcode) \(country)"
        let addressByLine = "\(street)\n\(city), \(state) \(postcode)\n\(country)"
        
        return (addressString, addressByLine)
    }
    
    fileprivate func insightlyURLFromParameters(_ path: String, parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = API.APIScheme
        components.host = API.APIHost
        components.path = path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
