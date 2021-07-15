//
//  HistoryTableViewController.swift
//  FoodRand
//
//  Created by Joey Hwang on 10/5/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class HistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<Restaurant>!
    private let alertService = AlertService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        if #available (iOS 13, *) {
            
        } else {
            searchBar.backgroundColor = .black
            searchBar.barTintColor = .black
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let err {
            print(err)
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        var predicate: NSPredicate?
        if searchText.count > 0 {
            predicate = NSPredicate(format: "(name contains[cd] %@)", searchText)
        } else {
            predicate = nil
        }
        
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let err {
            print(err)
        }

    }
    
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        container = appDelegate.persistentContainer
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<Restaurant>
        fetchedResultsController.delegate = self
        
        do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        initializeFetchedResultsController()
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurant = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        
        cell.configure(restaurant: restaurant)

        return cell
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let restaurant = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(restaurant)
            saveContext()
        }
    }
 
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            
            tableView.deleteRows(at: [indexPath!], with: .automatic)

        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if reachability.connection == .unavailable {
            let alertVC = alertService.alert(title: "No Internet Connection", body: "There was a problem communicating with Restie.") {
                
            }
            present(alertVC, animated: true)
        } else {
            guard let randomRestaurantViewController1 = storyboard?.instantiateViewController(withIdentifier: "RandomRestaurantViewController") else { return }
            navigationController?.pushViewController(randomRestaurantViewController1, animated: true)
            let randomRestaurantViewController = navigationController?.topViewController as? RandomRestaurantViewController
            let restaurant = fetchedResultsController.object(at: indexPath)
            let id = restaurant.value(forKey: "id") as? String
            yelpAPIClient.fetchBusiness(forId: id, locale: .english_unitedStates) { (business) in
                           if let business = business {
                            
                                randomRestaurantViewController?.saveButtonOutlet.alpha = 0.5
                                randomRestaurantViewController?.saveButtonOutlet.setTitle("Already Saved", for: .disabled) 
                               
                               var businessName: String?
                               if let name = business.name {
                                   
                                   businessName = name
                               } else {
                                   businessName = "No Name"
                               }
                               
                               if (businessName != "No Name") {
                                   gVariables.photos = [URL]()
                                   
                                   
                                   var restaurantAddress = ""
                                   var businessCategories = ""
                                   
                                   if let a = business.location?.displayAddress {
                                       for address in a {
                                           restaurantAddress += address + " "
                                       }
                                   }

                                   let Date12: String
                                   let Date13: String
                                   let Date14: String
                                   let Date15: String
                                   
                                   //Calculate hours
                                   var dayString = ""
                                   var day = Date().dayNumberOfWeek()!
                                   switch day {
                                   case 1:
                                       day = 6
                                   case 2:
                                       day = 0
                                   case 3:
                                       day = 1
                                   case 4:
                                       day = 2
                                   case 5:
                                       day = 3
                                   case 6:
                                       day = 4
                                   case 7:
                                       day = 5
                                   default:
                                       print("this should not run")
                                   }
                                   
                                   var day_increment = 0
                                   var day_index = 0
                                   var oneOrMoreStartEnd = 0
                                   
                                   for b in business.hours![0].open! {
                                       if (b.day! == day) {
                                           day_index = day_increment
                                           oneOrMoreStartEnd += 1
                                       }
                                       day_increment += 1
                                   }
                                   
                                   if (oneOrMoreStartEnd > 1) {
                                       day_index -= 1
                                   }
                                   
                                   print(business.hours![0].open!.count)
                                   print("day increment \(day_index), day \(day)")
                                   
                                   if var start = business.hours![0].open?[day_index].start {
                                       print("start \(start)")
                                       if (start.count == 3) {
                                           let dateFormatter = DateFormatter()
                                           dateFormatter.dateFormat = "HH:mm"
                                           start.insert(":", at: start.index(start.startIndex, offsetBy:1))
                                           let date = dateFormatter.date(from: start)
                                           dateFormatter.dateFormat = "h:mm a"
                                           Date12 = dateFormatter.string(from: date!)
                                           dayString += "\(Date12) - "
                                       } else {
                                           let dateFormatter = DateFormatter()
                                           dateFormatter.dateFormat = "HH:mm"
                                           start.insert(":", at: start.index(start.startIndex, offsetBy:2))
                                           let date = dateFormatter.date(from: start)
                                           dateFormatter.dateFormat = "h:mm a"
                                           Date12 = dateFormatter.string(from: date!)
                                           dayString += "\(Date12) - "
                                       }
                                   }
            
                                   if var end = business.hours![0].open?[day_index].end {
                                       print("end \(end)")
                                       if (end.count == 3) {
                                           let dateFormatter = DateFormatter()
                                           dateFormatter.dateFormat = "HH:mm"
                                           end.insert(":", at: end.index(end.startIndex, offsetBy:1))
                                           let date = dateFormatter.date(from: end)
                                           dateFormatter.dateFormat = "h:mm a"
                                           Date13 = dateFormatter.string(from: date!)
                                           dayString += "\(Date13)"
                                       } else {
                                           let dateFormatter = DateFormatter()
                                           dateFormatter.dateFormat = "HH:mm"
                                           end.insert(":", at: end.index(end.startIndex, offsetBy:2))
                                           let date = dateFormatter.date(from: end)
                                           dateFormatter.dateFormat = "h:mm a"
                                           Date13 = dateFormatter.string(from: date!)
                                           dayString += "\(Date13)"
                                       }
                                   }
                                   
                                   if (oneOrMoreStartEnd > 1) {
                                       if var start = business.hours![0].open?[day_index+1].start {
                                           dayString += ", "
                                           if (start.count == 3) {
                                               let dateFormatter = DateFormatter()
                                               dateFormatter.dateFormat = "HH:mm"
                                               start.insert(":", at: start.index(start.startIndex, offsetBy:1))
                                               let date = dateFormatter.date(from: start)
                                               dateFormatter.dateFormat = "h:mm a"
                                               Date14 = dateFormatter.string(from: date!)
                                               dayString += "\(Date14) - "
                                           } else {
                                               let dateFormatter = DateFormatter()
                                               dateFormatter.dateFormat = "HH:mm"
                                               start.insert(":", at: start.index(start.startIndex, offsetBy:2))
                                               let date = dateFormatter.date(from: start)
                                               dateFormatter.dateFormat = "h:mm a"
                                               Date14 = dateFormatter.string(from: date!)
                                               dayString += "\(Date14) - "
                                           }
                                       }
                                       
                                       if var end = business.hours![0].open?[day_index+1].end {
                                           if (end.count == 3) {
                                               let dateFormatter = DateFormatter()
                                               dateFormatter.dateFormat = "HH:mm"
                                               end.insert(":", at: end.index(end.startIndex, offsetBy:1))
                                               let date = dateFormatter.date(from: end)
                                               dateFormatter.dateFormat = "h:mm a"
                                               Date15 = dateFormatter.string(from: date!)
                                               dayString += "\(Date15)"
                                           } else {
                                               let dateFormatter = DateFormatter()
                                               dateFormatter.dateFormat = "HH:mm"
                                               end.insert(":", at: end.index(end.startIndex, offsetBy:2))
                                               let date = dateFormatter.date(from: end)
                                               dateFormatter.dateFormat = "h:mm a"
                                               Date15 = dateFormatter.string(from: date!)
                                               dayString += "\(Date15)"
                                           }
                                       }
                                   }
                                   
                                   if (dayString == "") {
                                       dayString = "Restaurant Hours Unavailable"
                                   }
                                   
                                   //Calculate distance
                                   let businessCoord = business.coordinates!
                                   let coordinate₀ = CLLocation(latitude: gVariables.locationCoord!.latitude, longitude: gVariables.locationCoord!.longitude)
                                   let coordinate₁ = CLLocation(latitude: businessCoord.latitude!, longitude: businessCoord.longitude!)
                                   
                                   let distanceInMiles = coordinate₀.distance(from: coordinate₁)*0.000621371
                                   
                                   let totalDistance = Double(round(100*distanceInMiles)/100)
                                
                                //business categories
                                   for category in business.categories! {
                                       businessCategories += category.title! + ", "
                                   }
                                   if restaurantAddress != "" {
                                       restaurantAddress.remove(at: restaurantAddress.index(before:restaurantAddress.endIndex))
                                       businessCategories.remove(at: businessCategories.index(before: businessCategories.endIndex))
                                       businessCategories.remove(at: businessCategories.index(before: businessCategories.endIndex))
                                   }
                                   
                                   let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
                                   
                                   tlabel.text = businessName
                                   tlabel.textColor = .white
                                   tlabel.font = UIFont(name:"AvenirNext-DemiBold", size: 25)
                                   
                                   tlabel.adjustsFontSizeToFitWidth = true
                                   tlabel.textAlignment = .center;
                                randomRestaurantViewController?.navigationItem.titleView = tlabel
                                   let imageString: String
                                   switch business.rating! {
                                   case 5.0:
                                       imageString = "large_5"
                                   case 4.5:
                                       imageString = "large_4_half"
                                   case 4.0:
                                       imageString = "large_4"
                                   case 3.5:
                                       imageString = "large_3_half"
                                   case 3:
                                       imageString = "large_3"
                                   case 2.5:
                                       imageString = "large_2_half"
                                   case 2:
                                       imageString = "large_2"
                                   case 1.5:
                                       imageString = "large_1_half"
                                   case 1:
                                       imageString = "large_1"
                                   default:
                                       imageString = "large_0"
                                   }
                                   print(business.rating!)
                                   let attachment = NSTextAttachment()
                                   attachment.image = UIImage(named: imageString)
                                   attachment.bounds = CGRect(x: 0, y: -3, width: 120, height: 22)
                                   let attachmentString = NSAttributedString(attachment: attachment)
                                   let myString = NSMutableAttributedString(string: "")
                                   
                                   myString.append(attachmentString)
                                   myString.append(NSMutableAttributedString(string: "  \(business.reviewCount!) Reviews, \(totalDistance) miles"))
                           
                                randomRestaurantViewController?.reviewLabel.attributedText = myString
                                   
                                   if let phone = business.displayPhone {
                                       if (phone == "") {
                                        randomRestaurantViewController?.phoneNumberLabel.text = "No Phone Number"
                                       } else {
                                        randomRestaurantViewController?.phoneNumberLabel.attributedText = NSAttributedString(string: phone, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                                       }
                                   }
                                randomRestaurantViewController?.addressLabel.attributedText = NSAttributedString(string: restaurantAddress, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                                randomRestaurantViewController?.hoursOpenLabel.text = "\(dayString)"
                                   
                                   
                                   if let price = business.price {
                                    randomRestaurantViewController?.typeLabel.text = "\(price) " + businessCategories
                                   } else {
                                    randomRestaurantViewController?.typeLabel.text = businessCategories
                                   }
                                   
                                   for photo in business.photos! {
                                       gVariables.photos.append(URL(string: photo)!)
                                   }
                                   
                                randomRestaurantViewController?.pageControl.numberOfPages = gVariables.photos.count
                                randomRestaurantViewController?.coordinates = business.coordinates!
                                randomRestaurantViewController?.restaurantName = businessName
                                randomRestaurantViewController?.businessUrl = URL(string: business.url!)
                                randomRestaurantViewController?.saveButtonOutlet.isEnabled = false
                               } else {
                                    randomRestaurantViewController?.title = "Error Getting Restaurant"
                                    randomRestaurantViewController?.pageControl.numberOfPages = 0
                                    gVariables.photos = []
                                    randomRestaurantViewController?.saveButtonOutlet.isEnabled = false
                               }
                            randomRestaurantViewController?.collectionView.reloadData()
                           }
            }
        }
    }
}


