//
//  ViewController.swift
//  Just
//
//  Created by dely on 2018. 5. 16..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    @IBOutlet weak var CoverImageView: UIImageView!
    @IBOutlet weak var SecureImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var flagOfImageView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func selectCoverButton(_ sender: UIButton) {
        openAlertActionTouched()
    }

    @IBAction func selectSecureButton(_ sender: UIButton) {
        openAlertActionTouched()
    }
    
    // 버튼 누르면 AlertAction 열림
    func openAlertActionTouched() {
        let alert =  UIAlertController(title: "사진 선택", message: "Choose Cover Image", preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "사진앨범", style: .default) {
            action in self.openLibraryTouched()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) {
            action in self.openCameraTouched()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // AlertAction에서 Library 눌렀을 때
    func openLibraryTouched() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // AlertAction에서 Camera 눌렀을 때
    func openCameraTouched() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("not Available")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        if !flagOfImageView {
            CoverImageView.image = image
            flagOfImageView = true
        } else {
            SecureImageView.image = image
            flagOfImageView = true
        }
        dismiss(animated: true, completion: nil)
    }

}

