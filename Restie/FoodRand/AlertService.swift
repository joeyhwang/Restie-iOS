//
//  AlertService.swift
//  FoodRand
//
//  Created by Joey Hwang on 8/19/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit

class AlertService {
    
    func alert(title: String, body: String, completion: @escaping () -> Void) -> AlertViewController {
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! AlertViewController
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.buttonAction = completion
        return alertVC
        
    }
}
