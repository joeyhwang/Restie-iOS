//
//  AlertViewController.swift
//  FoodRand
//
//  Created by Joey Hwang on 8/19/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    var alertTitle = String()
    
    var alertBody = String()
    
    var buttonAction: (() -> Void)?
    
    @IBAction func didTapOk(_ sender: Any) {
        dismiss(animated: true)
        
        buttonAction?()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    func setupView() {
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 10
        titleLabel.text = alertTitle
        bodyLabel.text = alertBody
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
}
