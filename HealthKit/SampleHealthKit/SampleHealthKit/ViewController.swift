//
//  ViewController.swift
//  SampleHealthKit
//
//  Created by Phani on 28/06/17.
//  Copyright © 2017 Mobileways. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var weights = [String]()

    var anchor :HKQueryAnchor =  HKQueryAnchor(fromValue: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        enableBGdelivaryFor(type: HKQuantityTypeIdentifier.bodyMass)
        readweights()
        observerForHK(type: HKQuantityTypeIdentifier.bodyMass)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func getNewweights(_ sender: Any) {
        readweights()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func enableBGdelivaryFor(type:HKQuantityTypeIdentifier)  {
        
        //IMPORTANT:Notes
        
        // to use this methos enanle backgroundmodes for ur app
        // add Privacy - Health Share Usage Description in ur plist file

        // user can set this logic in appdelegate also

        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            print("Unable to create quantity type")
            return
        }
        
        
        // Enable background delivery for weight
        HKHealthStore().enableBackgroundDelivery(for: quantityType, frequency: .immediate) {
            (success, error) in
            
            if error != nil {
                abort()
            }
        }
        
    }
    
    
    func observerForHK(type:HKQuantityTypeIdentifier){
        
        
        //IMPORTANT:Notes
        
        // to use this methos enanle backgroundmodes for ur app
        // add Privacy - Health Share Usage Description in ur plist file
        // this method called when app become active 
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            print("Unable to create quantity type")
            return
        }
        
        
        
        // request authorization and save a sample of the type of healthkit data required
        HKHealthStore().requestAuthorization(toShare: [], read: [quantityType]) {
            okay, error in
            
            // error in requesting authorization
            if error != nil {
                print(error ?? "")
                return
            }
            
            // requested authorization and was denied
            if !okay {
                print("Not authorized to read weight HealtKit data")
                return
            }

        
            
            
        let observerquery = HKObserverQuery(sampleType: quantityType, predicate: nil) {
            query, completionHandler, error in
            
            if error != nil {
                
                // Perform Proper Error Handling Here...
                print("*** An error occured while setting up the stepCount observer. \(error?.localizedDescription) ***")
                abort()
            }
            
            
            
            // Take whatever steps are necessary to update your app's data and UI
            // This may involve executing other queries
            
            // If you have subscribed for background updates you must call the completion handler here.
            
            self.getRecentlyaddedTypes(type: type)
            
            completionHandler()
            
        }
          
            
            HKHealthStore().execute(observerquery)

        }
        
    }
    
    
    func getRecentlyaddedTypes(type:HKQuantityTypeIdentifier)  {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            print("Unable to create quantity type")
            return
        }
        
        // request authorization and save a sample of the type of healthkit data required
        HKHealthStore().requestAuthorization(toShare: [], read: [quantityType]) {
            okay, error in
            
            // error in requesting authorization
            if error != nil {
                print(error ?? "")
                return
            }
            
            // requested authorization and was denied
            if !okay {
                print("Not authorized to read weight HealtKit data")
                return
            }

        let query1 = HKAnchoredObjectQuery(type: quantityType,
                                           predicate: nil,
                                           anchor: HKQueryAnchor(fromValue: 3),
                                           limit: Int(HKObjectQueryNoLimit)) { [unowned self](query, newSamples, deletedSamples, newAnchor, error) -> Void in
                                            
                                            guard let samples = newSamples as? [HKQuantitySample], let deleted = deletedSamples else {
                                                // Add proper error handling here...
                                                print("*** Unable to query for step counts: \(error?.localizedDescription) ***")
                                                abort()
                                            }
                                            
                                            // Process the results...
                                            
                                            for obj in samples {
                                                
                                                self.weights.append("\((obj as! HKQuantitySample).quantity)")

                                                print((obj as? HKQuantitySample)?.quantity)
                                                print((obj as? HKQuantitySample)?.quantityType)
                                                print(obj.startDate)
                                                print(obj.endDate)
                                                
                                            }
                                            
                                            
                                            for obj in deleted {
                                                print((obj as? HKQuantitySample)?.quantity)
                                                print((obj as? HKQuantitySample)?.quantityType)
                                                
                                            }
                                            
                                            self.tableView.reloadData()
                                            print("Done!")
        }
        
        HKHealthStore().execute(query1)
        }
        
    }
    
//    func readweight()  {
//    
//        // find out if HealthKit is on this device
//        guard HKHealthStore.isHealthDataAvailable() else {
//            print("No HealthKit on this device")
//            return
//        }
//        
//        // create a quantity type for storing body mass
//        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else {
//            print("Unable to create quantity type")
//            return
//        }
//        
//        // request authorization and save a sample of the type of healthkit data required
//        HKHealthStore().requestAuthorization(toShare: [], read: [quantityType]) {
//            okay, error in
//            
//            // error in requesting authorization
//            if error != nil {
//                print(error ?? "")
//                return
//            }
//            
//            // requested authorization and was denied
//            if !okay {
//                print("Not authorized to read weight HealtKit data")
//                return
//            }
//            
//            
//            
//            // create the query
//            let weightQuery = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 10, sortDescriptors: nil) {
//                
//                query, results, error in
//                
//                // error with query
//                if error != nil {
//                    print(error ?? "")
//                    return
//                }
//                
//                // check for valid results
//                guard let results = results else {
//                    print("No results of query")
//                    return
//                }
//                
//                // make sure there is at least one result to output
//                if results.count == 0 {
//                    print("Zero samples")
//                    return
//                }
//                
//                results.forEach({ (obj) in
//                    print(obj.metadata)
//                    print((obj as? HKQuantitySample)?.quantity)
//                    print((obj as? HKQuantitySample)?.quantityType)
//                    print(obj.startDate)
//                    print(obj.endDate)
//                })
//                
//                // extract the one sample
//                guard let bodymass = results[0] as? HKQuantitySample else {
//                    print("Type problem with weight")
//                    return
//                }
//                
//                
//                
//                print(bodymass.quantity)
//                print(bodymass.quantityType)
//            }
//            
//            self.observerForHK(type: HKQuantityTypeIdentifier.bodyMass)
//
//            // execute the query
//            HKHealthStore().execute(weightQuery)
//        }
//    }
//    
//    
//    
    func readweights()  {
       
        // find out if HealthKit is on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("No HealthKit on this device")
            return
        }
        
        // create a quantity type for storing body mass
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else {
            print("Unable to create quantity type")
            return
        }
        
        // request authorization and save a sample of the type of healthkit data required
        HKHealthStore().requestAuthorization(toShare: [], read: [quantityType]) {
            okay, error in
            
            // error in requesting authorization
            if error != nil {
                print(error ?? "")
                return
            }
            
            // requested authorization and was denied
            if !okay {
                print("Not authorized to read weight HealtKit data")
                return
            }
            
            

            
            // create the query
            let weightQuery = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 10, sortDescriptors: nil) {
                
                query, results, error in
                
                // error with query
                if error != nil {
                    print(error ?? "")
                    return
                }
                
                // check for valid results
                guard let results = results else {
                    print("No results of query")
                    return
                }
                
                // make sure there is at least one result to output
                if results.count == 0 {
                    print("Zero samples")
                    return
                }
                
                results.forEach({ (obj) in
                    self.weights.append("\((obj as! HKQuantitySample).quantity)")
//                    print(obj.metadata)
//                    print((obj as? HKQuantitySample)?.quantity)
//                    print((obj as? HKQuantitySample)?.quantityType)
//                    print(obj.startDate)
//                    print(obj.endDate)
                })
                
                self.tableView.reloadData()
                
                // extract the one sample
                guard let bodymass = results[0] as? HKQuantitySample else {
                    print("Type problem with weight")
                    return
                }
                
        
                
                print(bodymass.quantity)
                print(bodymass.quantityType)
            }
            
            // execute the query
            HKHealthStore().execute(weightQuery)
            

            
        }
    }

}



extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weights.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = weights[indexPath.row]
        return cell
    }
    
}
