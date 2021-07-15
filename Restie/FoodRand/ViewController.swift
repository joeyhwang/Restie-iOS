//
//  ViewController.swift
//  FoodRand
//
//  Created by Joey Hwang on 6/18/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreLocation
import CDYelpFusionKit
import NVActivityIndicatorView
import Reachability
import MapKit

class ViewController: UIViewController, ChildNameDelegate, NVActivityIndicatorViewable {
    private let size = CGSize(width: 30, height: 30)
    private let defaults = UserDefaults.standard
    private var pulsatingLayer: CAShapeLayer!
    private var cachedBusinesses = [CDYelpBusiness]()
    private var cached = false
    private let alertService = AlertService()
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var randomButton: UIButton!
    let locationService = LocationService()
    
    @IBAction func randomButton(_ sender: Any) {
        if reachability.connection == .none {
            let alertVC = alertService.alert(title: "No Internet Connection", body: "There was a problem communicating with Restie.") {
                
            }
            present(alertVC, animated: true)
        } else if (gVariables.viewModels.count > 0) {
            performSegue(withIdentifier: "randomRestaurantSegue", sender: nil)
            
        } else if (gVariables.locationCoord?.latitude == nil) {
            let alertVC = alertService.alert(title: "Unable to Retrieve Location", body: "") {
                
            }
            present(alertVC, animated: true)
            
        } else if (cachedBusinesses.count == 0 && gVariables.outOfResults == true) {
            let alertVC = alertService.alert(title: "No Restaurants", body: "There are no restaurants open with the current settings.") {
                
            }
            
            present(alertVC, animated: true)
        } else if (gVariables.outOfResults == true && gVariables.viewModels.count == 0) {
            let alertVC = alertService.alert(title: "Out of Restaurants", body: "All of the restaurants for this point are shown. Press Ok to refresh the current list of restaurants.") { [weak self] in
                self?.reloadRestaurants()
            }
            present(alertVC, animated: true)
            
        } else {
            //performSegue(withIdentifier: "emptyViewModelSegue", sender: nil)
            let alertVC = alertService.alert(title: "Out of Restaurants", body: "Click Ok! to find more restaurants.") { [weak self] in
                gVariables.filtered = false
                self?.startAnimating()
                let defaults2 = UserDefaults.standard
                let initialOffset = offsetArray[0]
                gVariables.currentOffset = initialOffset
                
                if (offsetArray.count == 0) {
                    gVariables.outOfResults = true
                } else {
                    offsetArray.remove(at: 0)
                }
                
                
                
                
                //distance
                var distance = defaults2.float(forKey: Keys.distance)
                if (distance == 0) {
                    distance = 40000
                } else {
                    distance = distance*1600
                }
                
                //max price rating
                let priceRating = defaults2.object(forKey: Keys.priceRating) as? Int ?? 0
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
                
                //category
                let chosenCategory = defaults2.string(forKey: Keys.category)
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
                
                for offset in stride(from: initialOffset, through: initialOffset+200 , by: 50) {
                    yelpAPIClient.searchBusinesses(byTerm: "Restaurants",
                                                   location: nil,
                                                   latitude: gVariables.locationCoord?.latitude,
                                                   longitude: gVariables.locationCoord?.longitude,
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
                                                        print("no businesses created")
                                                        gVariables.outOfResults = true
                                                    }
                                                    print("view models created")
                                                    print(gVariables.viewModels.count)
                    
                                                    self?.stopAnimating()            
                    }
                }
            }
            present(alertVC, animated: true)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restie"
        
        
        randomButton.layer.cornerRadius = 20
        randomButton.clipsToBounds = true
        
        let distance = defaults.float(forKey: Keys.distance)
        if (distance == 0) {
            distanceLabel.text = "\(Int(filters.distance)) miles"
        } else {
            distanceLabel.text = "\(Int(distance)) miles"
            if (Int(distance) == 1) {
                distanceLabel.text = "\(Int(distance)) mile"
            } else {
                distanceLabel.text = "\(Int(distance)) miles"
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start notifier")
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            let alertVC = self?.alertService.alert(title: "No Internet Connection", body: "There was a problem communicating with Restie.") {
                
            }
            self?.present(alertVC!, animated: true)
        }
        
    }
    
    @objc func internetChanged(note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection == .none {
            let alertVC = alertService.alert(title: "No Internet Connection", body: "There was a problem communicating with Restie.") {
                
            }
            present(alertVC, animated: true)
        }
    }
    
    public func startAnimating() {
        let size = CGSize(width:80.0, height: 80.0)
        startAnimating(size, message: "Loading Nearby Restaurants", messageFont: UIFont(name: "Avenir Next", size: 25), type: .ballSpinFadeLoader, color: .white, padding: 20, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor(rgb: 0x000000), textColor: .white, fadeInAnimation: nil)
    }
    
    public func stopAnimating() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.02
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.7
        animationGroup.repeatCount = 999999
        animationGroup.animations = [pulse1]
        randomButton.layer.add(animationGroup, forKey: "pulse")
        if (gVariables.settingsLoadingAnimation) {
            startAnimating()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
            cached = false
            cachedBusinesses = []
            gVariables.settingsLoadingAnimation = false
        } else {
            print("settings loading animation is false")
        }
    }
    
    func dataChanged(distance: Float) {
        distanceLabel.text = "Distance: \(Int(distance)) miles"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let settingsTableViewController = segue.destination as? SettingTableViewController {
            settingsTableViewController.delegate = self
        }
        
        if (gVariables.viewModels.count > 0) {
            if let randomRestaurantViewController = segue.destination as? RandomRestaurantViewController {
                
                if (gVariables.filtered == false) {
                    var filteredArray = [CDYelpBusiness]()
                    var isFastFood = false
                    let fastFoodSwitchValue = defaults.bool(forKey: Keys.fastFoodSwitchValue)
                    
                    var distance = Float(Int(defaults.float(forKey: Keys.distance)))
                    if (distance == 0) {
                        distance = 25
                    }
                    
                    for business in gVariables.viewModels  {
                        let businessCoord = business.coordinates!
                        let coordinate₀ = CLLocation(latitude: gVariables.locationCoord!.latitude, longitude: gVariables.locationCoord!.longitude)
                        let coordinate₁ = CLLocation(latitude: businessCoord.latitude!, longitude: businessCoord.longitude!)
                        
                        let distanceInMiles = coordinate₀.distance(from: coordinate₁)*0.000621371
                        let restaurantDistance = Float(round(100*distanceInMiles)/100)
                        
                        if distance >= restaurantDistance {
                            filteredArray.append(business)
                        }
                    }
                    gVariables.viewModels = filteredArray
                    filteredArray = []
                    print("Distance Filtered")
                    print(gVariables.viewModels.count)
                    //Filter Fast Food
                    if (fastFoodSwitchValue == false) {
                        for bus in gVariables.viewModels {
                            for category in bus.categories! {
                                if (category.title == "Fast Food" ) {
                                    isFastFood = true
                                }
                            }
                            if (isFastFood == false) {
                                filteredArray.append(bus)
                            } else {
                                isFastFood = false
                            }
                        }
                        gVariables.viewModels = filteredArray
                        filteredArray = []
                        print("fast food filtered")
                        print(gVariables.viewModels.count)
                    }
                    //filter ratings
                    let rating = defaults.object(forKey: Keys.starsRating) as? Int ?? 0
                    for bus in gVariables.viewModels {
                        if (rating == 0 || rating == 1) {
                            break
                        } else if (Double(rating) <= bus.rating!) {
                            filteredArray.append(bus)
                        }
                    }
                    if (rating != 0 && rating != 1) {
                        
                        gVariables.viewModels = filteredArray
                    }
                    print("filtered ratings")
                    gVariables.filtered = true
                    filteredArray = []
                }
                
                print(gVariables.viewModels.count)
                if (gVariables.viewModels.count > 0) {
                    let number = Int.random(in: 0 ... gVariables.viewModels.count - 1)
                    let randomRestaurant = gVariables.viewModels[number]
                    let id = randomRestaurant.id!
                    print(id)
                    yelpAPIClient.fetchBusiness(forId: id, locale: .english_unitedStates) { (business) in
                        if let business = business {
                            
                            
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
                                /*
                                
                                for address in (business.location?.displayAddress)! {
                                    restaurantAddress += address + " "
                                }
                                */
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
                                /*
                                let request:MKDirections.Request = MKDirections.Request()
                                
                                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: gVariables.locationCoord!.latitude, longitude:gVariables.locationCoord!.longitude), addressDictionary: nil))
                                
                                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: businessCoord.latitude!, longitude: businessCoord.longitude!), addressDictionary: nil))
                                
                                request.transportType = .automobile
                                let directions = MKDirections(request: request)
                                directions.calculate(completionHandler: { (response, error) in
                                    
                                    if error == nil {
                                        let route = response!.routes[0] as MKRoute
                                        let distance = route.distance
                                        totalDistance = Double(round(100*distance*0.000621371)/100)
                                    }
                                })
                                */
                                
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
                                randomRestaurantViewController.navigationItem.titleView = tlabel
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
                        
                                randomRestaurantViewController.reviewLabel.attributedText = myString
                                
                                if let phone = business.displayPhone {
                                    if (phone == "") {
                                        randomRestaurantViewController.phoneNumberLabel.text = "No Phone Number"
                                    } else {
                                        randomRestaurantViewController.phoneNumberLabel.attributedText = NSAttributedString(string: phone, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                                    }
                                }
                                randomRestaurantViewController.addressLabel.attributedText = NSAttributedString(string: restaurantAddress, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                                randomRestaurantViewController.hoursOpenLabel.text = "\(dayString)"
                                
                                
                                if let price = business.price {
                                    randomRestaurantViewController.typeLabel.text = "\(price) " + businessCategories
                                } else {
                                    randomRestaurantViewController.typeLabel.text = businessCategories
                                }
                                
                                for photo in business.photos! {
                                    gVariables.photos.append(URL(string: photo)!)
                                }
                                
                                randomRestaurantViewController.pageControl.numberOfPages = gVariables.photos.count
                                randomRestaurantViewController.coordinates = business.coordinates!
                                randomRestaurantViewController.restaurantName = businessName
                                randomRestaurantViewController.businessUrl = URL(string: business.url!)
                                randomRestaurantViewController.businessId = business.id
                            } else {
                                randomRestaurantViewController.title = "Error Getting Restaurant"
                                randomRestaurantViewController.pageControl.numberOfPages = 0
                                gVariables.photos = []
                                
                                
                            }
                            randomRestaurantViewController.collectionView.reloadData()
                        }
                    }
                    if (cached == false) {
                        cachedBusinesses.append(randomRestaurant)
                    }
                    print(gVariables.viewModels.count)
                    gVariables.viewModels.remove(at: number)
                
                } else {
                    //filtered list count = 0
                    let alertVC = alertService.alert(title: "No Restaurants", body: "There are no restaurants open with the current settings.") {
                        
                    }
                    gVariables.filtered = false
                    present(alertVC, animated: true)
                    print("filtered list is none")
                }
            }
        } else {
            print("0 left")
        }
    }
   fileprivate func reloadRestaurants() {
        offsetArray = [0,250,500,750]
        gVariables.filtered = false
        gVariables.viewModels = cachedBusinesses
        cached = true
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
