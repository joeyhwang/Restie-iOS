//
//  HistoryTableViewCell.swift
//  FoodRand
//
//  Created by Joey Hwang on 10/5/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var restaurantName: UILabel!
    
    @IBOutlet weak var dateAdded: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(restaurant: NSManagedObject) {
        let date = restaurant.value(forKey: "date") as? Date
        restaurantName.text = restaurant.value(forKey: "name") as? String
        restaurantName.adjustsFontSizeToFitWidth = true
        dateAdded.text = date!.toString(dateFormat: "MM-dd-yy")
        
    }

}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

