//
//  RatingControl.swift
//  FoodRand
//
//  Created by Joey Hwang on 8/3/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//
import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    let defaults = UserDefaults.standard
    
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
            defaults.set(rating, forKey: Keys.starsRating)
        }
    }
    @IBInspectable var starSize: CGSize = CGSize(width: 30.0, height: 30.0) {
        didSet {
            setUpButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setUpButtons()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpButtons()
    }
    
    private func setUpButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "star_full", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "star_empty", in: bundle, compatibleWith: self.traitCollection)
        //let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        for _ in 0..<starCount {
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(filledStar, for: .highlighted)
            button.setImage(filledStar, for: [.highlighted,.selected])
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
    }
    
    
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button) is not in the ratingbuttons array:  \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    
    
}
