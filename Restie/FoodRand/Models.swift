//
//  Models.swift
//  FoodRand
//
//  Created by Joey Hwang on 6/24/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//
import Foundation
import CoreLocation
import CDYelpFusionKit
import Reachability

let yelpAPIClient = CDYelpAPIClient(apiKey: "")

struct Variables {
    var distance: Float = 25
    var photos = [URL]()
    var locationCoord: CLLocationCoordinate2D?
    var viewModels = [CDYelpBusiness]()
    var settingsChanged = false
    var currentOffset = 0
    var filtered = false
    var settingsLoadingAnimation = false
    var outOfResults = false
    var internetConnection = true
    
}

//var offsetArray: [Int] = [50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950]
var offsetArray: [Int] = [0,250,500,750]
let reachability = try! Reachability()

struct  Filters {
    var distance: Float = 25
    var priceRating: Int = 0
    var starsRating: Int = 0
    var fastFoodSwitch: Bool = false
    var changedSettings: Bool = false
}

struct Keys {
    static let distance = "distance"
    static let priceRating = "priceRating"
    static let starsRating = "starsRating"
    static let fastFoodSwitch = "fastFoodSwitch"
    static let fastFoodSwitchValue = "fastFoodSwitchValue"
    static let category = "category"
}

struct category {
    static let All = "All"
    static let American = "American"
    static let Breakfast = "Breakfast & Brunch"
    static let BubbleTea = "Bubble Tea"
    static let Burgers = "Burgers"
    static let Chinese = "Chinese"
    static let Coffee = "Coffee & Tea"
    static let Dessert = "Dessert"
    static let Donuts = "Donuts"
    static let French = "French"
    static let Greek = "Greek"
    static let Hawaiian = "Hawaiian"
    static let IceCream = "Ice Cream"
    static let Indian = "Indian"
    static let Italian = "Italian"
    static let Japanese = "Japanese"
    static let Korean = "Korean"
    static let Mediterranean = "Mediterranean"
    static let Mexican = "Mexican"
    static let Mongolian = "Mongolian"
    static let Noodles = "Noodles"
    static let Pizza = "Pizza"
    static let Ramen = "Ramen"
    static let Sandwiches = "Sandwiches"
    static let Seafood = "Seafood"
    static let Spanish = "Spanish"
    static let Steakhouses = "Steakhouses"
    static let Taiwanese = "Taiwanese"
    static let Thai = "Thai"
    static let Vegetarian = "Vegetarian"
    static let Vietnamese = "Vietnamese"
    static let Waffles = "Waffles"
}

var gVariables = Variables()

var filters = Filters()

extension CLLocationCoordinate2D: Decodable {
    enum CodingKeys: CodingKey {
        case latitude
        case longitude
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}

