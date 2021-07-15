//
//  SettingsTableViewController.swift
//  FoodRand
//
//  Created by Joey Hwang on 8/4/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//
import UIKit
import StoreKit
import CDYelpFusionKit
import MessageUI

protocol ChildNameDelegate {
    func dataChanged(distance: Float)
}

class SettingTableViewController: UITableViewController {
    var delegate: ChildNameDelegate?
    private let defaults = UserDefaults.standard
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var mySwitch: UISwitch!
    
    @IBOutlet weak var fastFoodLabel: UILabel!
    @IBOutlet weak var minStarsLabel: UILabel!
    @IBOutlet weak var maxPriceLabel: UILabel!
    
    @IBOutlet weak var starsRatingOutlet: RatingControl!
    @IBOutlet weak var categoryTextField: UITextField!
    
    private let categories = [category.All, category.American, category.Breakfast, category.BubbleTea,
                              category.Burgers, category.Chinese, category.Coffee ,category.Dessert, category.Donuts, category.French,
                              category.Greek, category.Hawaiian, category.IceCream ,category.Indian, category.Italian,
                              category.Japanese, category.Korean, category.Mediterranean, category.Mexican,
                              category.Mongolian, category.Noodles, category.Pizza, category.Ramen, category.Sandwiches,
                              category.Seafood, category.Spanish, category.Steakhouses, category.Taiwanese,
                              category.Thai, category.Vegetarian, category.Vietnamese, category.Waffles]
    
    private var selectedCategory: String?
    private var categoryChanged = false
    private var distanceL = 0
    private var priceRatingL = 0
    private var starRatingL = 0
    private var fastFoodSwitchL = false
    private var categoryL = ""
    
    @IBOutlet weak var priceRatingOutlet: PriceRatingControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        title = "Settings"

        if #available (iOS 13, *) {
            
        } else {
            categoryTextField.backgroundColor = .darkGray
        }
        
        
        //distance
        let distance = defaults.float(forKey: Keys.distance)
        
        if (distance == 0) {
            distanceSlider.value = filters.distance
            distanceLabel.text = "\(Int(filters.distance)) miles"
        } else {
            distanceSlider.value = distance
            if (Int(distanceSlider.value) == 1) {
                distanceLabel.text = "\(Int(distanceSlider.value)) mile"
            } else {
                distanceLabel.text = "\(Int(distanceSlider.value)) miles"
            }
        }
        distanceL = Int(distanceSlider.value)
        
        //fast food
        let ffSwitch = defaults.bool(forKey: Keys.fastFoodSwitch)
        if (ffSwitch == false) {
            mySwitch.isOn = false
        } else {
            let fastFoodSwitchValue = defaults.bool(forKey: Keys.fastFoodSwitchValue)
            
            mySwitch.isOn = fastFoodSwitchValue
            if (fastFoodSwitchValue) {
                fastFoodLabel.text = "Include Fast Food: On"
            } else {
                fastFoodLabel.text = "Include Fast Food: Off"
            }
        }
        fastFoodSwitchL = mySwitch.isOn
        
        
        //Min stars: ratings are from 0-5 so 100 will not be reached unless defaults is not set
        let starRating = defaults.object(forKey: Keys.starsRating) as? Int ?? 100
        if (starRating != 100) {
            //minStarsLabel.text = "Minimum Stars: \(starRating)"
            starsRatingOutlet.rating = starRating
            starRatingL = starsRatingOutlet.rating
            
        }
        
        //Max $$$$
        let priceRating = defaults.object(forKey: Keys.priceRating) as? Int ?? 100
        if (priceRating != 100) {
            var priceText: String
            switch priceRating {
            case 1:
                priceText = "$"
            case 2:
                priceText = "$$"
            case 3:
                priceText = "$$$"
            case 4:
                priceText = "$$$$"
            default:
                priceText = "$$$$"
                
            }
            //maxPriceLabel.text = "Maximum Price: \(priceText)"
            priceRatingOutlet.rating = priceRating
            priceRatingL = priceRatingOutlet.rating
        }
        
        //Set Category Text
        if let cat = defaults.string(forKey: Keys.category) {
            categoryTextField.text = cat
            
        } else {
            categoryTextField.text = category.All
            
        }
        categoryL = categoryTextField.text ?? "All"
        createCategoryPicker()
        createToolBar()
    }
    
    @IBAction func fastFoodSwitch(_ sender: Any) {
        defaults.set(true, forKey: Keys.fastFoodSwitch)
        if mySwitch.isOn {
            defaults.set(true, forKey: Keys.fastFoodSwitchValue)
            fastFoodLabel.text = "Include Fast Food: On"
        } else {
            defaults.set(false, forKey: Keys.fastFoodSwitchValue)
            fastFoodLabel.text = "Include Fast Food: Off"
        }
    }
    
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        if (Int(distanceSlider.value) == 1) {
            distanceLabel.text = "\(Int(distanceSlider.value)) mile"
        } else {
            distanceLabel.text = "\(Int(distanceSlider.value)) miles"
        }
        
        defaults.set(distanceSlider.value, forKey: Keys.distance)
        changeDistanceLabel(data: defaults.float(forKey: Keys.distance))
    }
    
    @IBAction func RateButton(_ sender: UIButton) {
        //https://apps.apple.com/us/app/restie/id1480277750
        //SKStoreReviewController.requestReview()
        let appID = "1480277750"
        let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review" // (Option 2) Open App Review Page

        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url) // openURL(_:) is deprecated from iOS 10.
        }

    }
    
    
    private func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["restiesupp@gmail.com"])
        composer.setSubject("Report a bug")
        composer.setMessageBody("Description of bug: ", isHTML: false)
        present(composer,animated: true)
    }
    
    
    @IBAction func emailButton(_ sender: Any) {
        showMailComposer()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        headerView.backgroundColor = UIColor(rgb: 0x000000)
        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 8, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        if (section == 1) {
            label.text = "Other"
        } else {
            label.text = "General"
        }
        
        label.font = UIFont(name:"Avenir Next", size: 25) // my custom font
        label.textColor = .white
        
        //label.backgroundColor = UIColor(rgb: 0x9F85FF)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func changeDistanceLabel(data: Float) {
        delegate?.dataChanged(distance: data)
    }
    
    private func createCategoryPicker() {
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        categoryTextField.inputView = categoryPicker
        //categoryPicker.backgroundColor = .black
        
        var chosen = 0
        print("beef")
        for cat in categories {
            if (cat == categoryTextField.text) {
                break
            }
            chosen += 1
        }
        if (categories[chosen] != categoryL) {
            categoryChanged = true
        } else {
            categoryChanged = false
        }
        categoryPicker.selectRow(chosen, inComponent: 0, animated: true)
        
        
    }
    
    private func createToolBar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
       //toolbar.barTintColor = .white
        //toolbar.tintColor = UIColor(rgb: 0x8E04FF)
        
        let doneButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(SettingTableViewController.dismissKeyboard) )
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        categoryTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        defaults.set(categoryTextField.text, forKey: Keys.category)
        if (categoryL != defaults.string(forKey: Keys.category)) {
            categoryChanged = true
        } else {
            categoryChanged = false
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (priceRatingL != priceRatingOutlet.rating || distanceL != Int(distanceSlider.value) || starRatingL != starsRatingOutlet.rating || categoryChanged == true) {
            gVariables.settingsChanged = true
        }
        
        
        
        if (gVariables.settingsChanged && gVariables.locationCoord?.latitude != nil) {
            gVariables.outOfResults = false
            gVariables.settingsLoadingAnimation = true
            gVariables.viewModels = []
            offsetArray = [250,500,750]
            
            //distance
            let distance = Int(distanceSlider.value * 1600)
            print(distance)
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
            
            //Category
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
            
            for offset in stride(from: 0, through: 200 , by: 50) {
                
                yelpAPIClient.searchBusinesses(byTerm: "Restaurants",
                                               location: nil,
                                               latitude: gVariables.locationCoord?.latitude,
                                               longitude: gVariables.locationCoord?.longitude,
                                               radius: distance,
                                               categories: categoryArray,
                                               locale: .english_unitedStates,
                                               limit: 50,
                                               offset: offset,
                                               sortBy: nil,
                                               priceTiers: priceRatingArray,
                                               openNow: true,
                                               openAt: nil,
                                               attributes: nil) { (response) in
                                                
                                                if let response = response,
                                                    let businesses = response.businesses,
                                                    businesses.count > 0 {
                                                    for bus in businesses {
                                                        gVariables.viewModels.append(bus)
                                                    }
                                                    
                                                } else {
                                                    print("fail")
                                                    gVariables.outOfResults = true
                                                }
                                                print("filtered settings view models created")
                                                print(gVariables.viewModels.count)
                                                gVariables.filtered = false
                }
            }
        }
        if (fastFoodSwitchL != mySwitch.isOn) {
            print("fastFoodSwitch changed")
            gVariables.filtered = false
        }
        
        gVariables.settingsChanged = false
    }
    
    
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCategory = categories[row]
        categoryTextField.text = selectedCategory
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        //label.textColor = UIColor(rgb: 0x8E04FF)
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next", size: 22)
        
        label.text = categories[row]
        
        return label
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            //show error alert
            controller.dismiss(animated:true)
            return
        }
        
        switch result {
        case.cancelled:
            print("cancelled")
        case .failed:
            print("failed to send")
        case .saved:
            print("saved")
        case .sent:
            print("email sent")
        @unknown default:
            print("unknown err")
        }
        controller.dismiss(animated: true)
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
