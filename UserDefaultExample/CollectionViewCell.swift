//
//  CollectionViewCell.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 04/03/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoIndicator: UIImageView!
//    @IBOutlet weak var checkmarkView: SSCheckMark!
    @IBOutlet weak var checkmarkView: UIImageView!
    
//    var checkmarkView: SSCheckMark!
    
//            override var isSelected: Bool {
//                didSet {
//                    checkmarkView.isHighlighted = isSelected ? false : true
//                }
//            }


//        override var isSelected: Bool {
//            didSet {
//                print("override var isSelected: Bool {")
//                checkmarkView.isHidden = isSelected ? false : true
//            }
//        }
    
//    override var isSelected: Bool {
//        didSet {
//            self.layer.borderWidth = 3.0
//            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
//        }
//    }
}
