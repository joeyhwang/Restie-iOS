//
//  AppDelegate.swift
//  FoodRand
//
//  Created by Joey Hwang on 6/18/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreLocation
import CDYelpFusionKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let locationService = LocationService()
    var window: UIWindow?
    let defaults = UserDefaults.standard
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let nav = storyboard
            .instantiateViewController(withIdentifier: "NavigationStoryboard") as? UINavigationController
        self.navigationController = nav
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        /*
        var locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        */
        
        switch locationService.status {
        case .notDetermined, .denied, .restricted:
            locationService.requestLocationAuthorization()
        default:
            print("Location service enabled")
        }
        
        locationService.didChangeStatus = { [weak self] success in
            if success {
                print("start updating location")
                self?.locationService.startUpdatingLocation()
                //self?.locationService.getLocation()
                
            }
        }
        var run = false
        
        locationService.newLocation = { [weak self] result in
            switch result {
            case .success(let location):
                if (run == false) {
                (self?.navigationController?.topViewController as? ViewController)?.startAnimating()
                print("success getting location")
                //self?.locationService.stopUpdatingLocation()
                self?.createViewModelList(with: location.coordinate)
                run = true
                }
                gVariables.locationCoord = location.coordinate
            case .failure(let error):
                print("Error getting the users location \(error)")
            }
        }

        return true
    }
    
    private func createViewModelList(with coordinate: CLLocationCoordinate2D) {
        //offset
        let initialOffset = offsetArray[0]
        gVariables.currentOffset = initialOffset
        offsetArray.remove(at: 0)
        
        //distance
        var distance = defaults.float(forKey: Keys.distance)
        if (distance == 0) {
            distance = 40000
        } else {
            distance = distance*1600
        }
        
        
        //max price rating
        let priceRating = defaults.object(forKey: Keys.priceRating) as? Int ?? 0
        var priceRatingArray: [CDYelpPriceTier]?
        switch priceRating {
        case 1:
            priceRatingArray = [.oneDollarSign]
        case 2:
            priceRatingArray = [.oneDollarSign,.twoDollarSigns]
        case 3:
            priceRatingArray = [.oneDollarSign,.twoDollarSigns,.threeDollarSigns]
        default:
            priceRatingArray = nil
        }
        
        let chosenCategory = defaults.string(forKey: Keys.category)
        var categoryArray = [CDYelpCategoryAlias]()
        switch chosenCategory {
        case category.All:
            categoryArray.append(.restaurants)
        case category.American:
            categoryArray.append(.traditionalAmerican)
            categoryArray.append(.newAmerican)
        case category.Breakfast:
            categoryArray.append(.breakfastAndBrunch)
        case category.BubbleTea:
            categoryArray.append(.bubbleTea)
        case category.Burgers:
            categoryArray.append(.burgers)
        case category.Chinese:
            categoryArray.append(.chinese)
        case category.Coffee:
            categoryArray.append(.coffeeshops)
            categoryArray.append(.coffeeAndTea)
            categoryArray.append(.coffeeRoasteries)
        case category.Dessert:
            categoryArray.append(.desserts)
        case category.Donuts:
            categoryArray.append(.donuts)
        case category.French:
            categoryArray.append(.french)
        case category.Greek:
            categoryArray.append(.greek)
        case category.Hawaiian:
            categoryArray.append(.hawaiian)
        case category.IceCream:
            categoryArray.append(.iceCreamAndFrozenYogurt)
        case category.Indian:
            categoryArray.append(.indian)
        case category.Italian:
            categoryArray.append(.italian)
        case category.Japanese:
            categoryArray.append(.japanese)
        case category.Korean:
            categoryArray.append(.korean)
        case category.Mediterranean:
            categoryArray.append(.mediterranean)
        case category.Mexican:
            categoryArray.append(.mexican)
        case category.Mongolian:
            categoryArray.append(.mongolian)
        case category.Noodles:
            categoryArray.append(.noodles)
        case category.Pizza:
            categoryArray.append(.pizza)
        case category.Ramen:
            categoryArray.append(.ramen)
        case category.Sandwiches:
            categoryArray.append(.sandwiches)
        case category.Seafood:
            categoryArray.append(.seafood)
        case category.Spanish:
            categoryArray.append(.spanish)
        case category.Steakhouses:
            categoryArray.append(.steakhouses)
        case category.Taiwanese:
            categoryArray.append(.taiwanese)
        case category.Thai:
            categoryArray.append(.thai)
        case category.Vegetarian:
            categoryArray.append(.vegan)
            categoryArray.append(.vegetarian)
        case category.Vietnamese:
            categoryArray.append(.vietnamese)
        case category.Waffles:
            categoryArray.append(.waffles)
        default:
            categoryArray.append(.restaurants)
        
        }
        var increment = 0
        print(distance)
        print(Int(distance))
        for offset in stride(from: initialOffset, through: initialOffset+200 , by: 50) {
        
            yelpAPIClient.searchBusinesses(byTerm: "Restaurants",
                                           location: nil,
                                           latitude: coordinate.latitude,
                                           longitude: coordinate.longitude,
                                           radius: Int(distance),
                                           categories: categoryArray,
                                           locale: .english_unitedStates,
                                           limit: 50,
                                           offset: offset,
                                           sortBy: nil,
                                           priceTiers: priceRatingArray,
                                           openNow: true,
                                           openAt: nil,
                                           attributes: nil) { [weak self] (response) in
                                            
                                            
                                            if let response = response,
                                                let businesses = response.businesses,
                                                businesses.count > 0 {
                                                for bus in businesses {
                                                    gVariables.viewModels.append(bus)
                                                }
                                                
                                            } else {
                                                print("no view models created")
                                                gVariables.outOfResults = true
                                                
                                            }
                                            print("view models created")
                                            print(gVariables.viewModels.count)
                                            increment += 1
                                            
                                            if (increment == 5) {
                                                (self?.navigationController?.topViewController as? ViewController)?.stopAnimating()
                                            }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("will resign active")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("application did become active")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
}


