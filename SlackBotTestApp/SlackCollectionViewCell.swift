//
//  SlackCollectionViewCell.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-10-30.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKCore

class SlackCollectionViewCell: UICollectionViewCell, SlackCell {
    @IBOutlet weak var nameLabel: UILabel!
    var user: User? = nil

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = (self.isSelected) ? UIColor.black.withAlphaComponent(0.25) : .black
            self.nameLabel.textColor = (self.isSelected) ? .black : .white
            self.layer.shadowOpacity = (self.isSelected) ? 0.5 : 0.0
            self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
            self.layer.shadowRadius = self.bounds.width / 2
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        }
    }

    func displayCell() {
        self.layer.cornerRadius = self.bounds.width / 2
        self.nameLabel.text = self.user?.defaultRealName
    }
}
