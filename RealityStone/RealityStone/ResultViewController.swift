//
//  ResultViewController.swift
//  RealityStone
//
//  Created by dely on 2018. 10. 21..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    private var realImage: UIImage!
    @IBOutlet weak var resultImageView: UIImageView!
    
    @IBAction func saveButton(_ sender: Any) {
        if let image = resultImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultImageView.image = ImageInformation.shared.image
    }

}
