//
//  ActivityIndicatorViewController.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-10-14.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit

protocol ActivityIndicatorDelegate: class {
    func doneDownload()
}

class ActivityIndicatorViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    weak var delegate: ActivityIndicatorDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.activityIndicator.startAnimating()
    }
}
