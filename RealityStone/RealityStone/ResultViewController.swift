//
//  ResultViewController.swift
//  RealityStone
//
//  Created by dely on 2018. 10. 21..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    @IBOutlet weak var resultImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultImageView.image = ImageInformation.shared.image
    }

}
