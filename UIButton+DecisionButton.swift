//
//  UIButton+DecisionButton.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-07-31.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit

extension UIButton {
    class func decisionButton(in view: UIView, title: String, y: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        view.addSubview(button)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.sizeToFit()
        button.frame = CGRect(x: (view.bounds.width - button.frame.width) / 2,
                              y: y,
                              width: button.frame.width,
                              height: button.frame.height)
        return button
    }
}
