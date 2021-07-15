//
//  RandomRestaurantViewController.swift
//  FoodRand
//
//  Created by Joey Hwang on 6/24/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import MapKit
import CDYelpFusionKit
import AlamofireImage
import CoreData
class RandomRestaurantViewController: UIViewController {
    
    
    @IBOutlet weak var saveButtonOutlet: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var openInYelpOutlet: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var hoursOpenLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    var coordinates: CDYelpCoordinates?
    var photos: [URL]?
    var restaurantName: String?
    var businessUrl: URL?
    var businessId: String?
    private let alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(DetailsCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(RandomRestaurantViewController.addressTapped))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(addressTap)
        
        let phoneNumberTap = UITapGestureRecognizer(target: self, action: #selector(RandomRestaurantViewController.phoneNumberTapped))
        phoneNumberLabel.isUserInteractionEnabled = true
        phoneNumberLabel.addGestureRecognizer(phoneNumberTap)
        
        saveButtonOutlet.setTitle("Saved!", for: .disabled)
        
        
        saveButtonOutlet.layer.cornerRadius = 25
        saveButtonOutlet.layer.borderWidth = 1.0
        saveButtonOutlet.layer.borderColor = UIColor.white.cgColor
        
        openInYelpOutlet.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        /*
        let fullString = NSMutableAttributedString(string: "Open In ")
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "Yelp_trademark_RGB")
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.append(imageString)
        openInYelpOutlet.setAttributedTitle(fullString, for: .normal)
        openInYelpOutlet.setAttributedTitle(fullString, for: .highlighted)
        openInYelpOutlet.setAttributedTitle(fullString, for: .selected)
        
        openInYelpOutlet.titleLabel?.numberOfLines = 0
        */
        
    }
    
    @objc func phoneNumberTapped(sender: UITapGestureRecognizer) {
        if (phoneNumberLabel.text! != "No Phone Number") {
            phoneNumberLabel.text?.makeACall()
        }
    }
    
    @objc func addressTapped(sender:UITapGestureRecognizer) {
        
        let coordinate = CLLocationCoordinate2DMake(coordinates!.latitude!, coordinates!.longitude!)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = restaurantName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        /*
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinates!.latitude!),\(coordinates!.longitude!)&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        }
*/
    }
    /*
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        if let url = businessUrl {
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityController, animated:true, completion: nil)
        }
    }
    */
    @IBAction func openInYelp(_ sender: Any) {
        if let url = businessUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    
    @IBAction func saveRestaurantButton(_ sender: Any) {
        self.save()
        saveButtonOutlet.isEnabled = false
        saveButtonOutlet.alpha = 0.5
        let alertVC = alertService.alert(title: "\(restaurantName!)", body: "Saved to Favorites.") {
            
        }
        present(alertVC, animated: true)
        
    }
    
    //this is the share button until i learn how to change it
    @IBAction func saveData(_ sender: UIBarButtonItem) {
        if let url = businessUrl {
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityController, animated:true, completion: nil)
        }
    }
    
    func save() {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

      let managedContext = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "Restaurant", in: managedContext)!
      let restaurant = NSManagedObject(entity: entity, insertInto: managedContext)
      restaurant.setValue(restaurantName, forKeyPath: "name")
        restaurant.setValue(businessId, forKeyPath: "id")
        restaurant.setValue(Date(), forKeyPath: "date")
        print(Date())
        
      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
}

extension RandomRestaurantViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gVariables.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! DetailsCollectionViewCell
        
        cell.imageView.af_setImage(withURL: gVariables.photos[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        
        pageControl.currentPage = Int(x / view.frame.width)
    }
}

extension String {
    
    func extractAll(type: NSTextCheckingResult.CheckingType) -> [NSTextCheckingResult] {
        var result = [NSTextCheckingResult]()
        do {
            let detector = try NSDataDetector(types: type.rawValue)
            result = detector.matches(in: self, range: NSRange(startIndex..., in: self))
        } catch { print("ERROR: \(error)") }
        return result
    }
    
    func to(type: NSTextCheckingResult.CheckingType) -> String? {
        let phones = extractAll(type: type).compactMap { $0.phoneNumber }
        switch phones.count {
        case 0: return nil
        case 1: return phones.first
        default: print("ERROR: Detected several phone numbers"); return nil
        }
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeACall() {
        guard   let number = to(type: .phoneNumber),
            let url = URL(string: "tel://\(number.onlyDigits())"),
            UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
