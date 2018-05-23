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

    @IBOutlet weak var coverPixel: UILabel!
    @IBOutlet weak var securePixel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var secureImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var flagOfImageView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coverTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertActionTouched(tapGestureRecognizer:)))
        let secureTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertActionTouched(tapGestureRecognizer:)))
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(coverTapGesture)
        secureImageView.isUserInteractionEnabled = true
        secureImageView.addGestureRecognizer(secureTapGesture)
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // imageView 누르면 AlertAction 열림
    @objc func openAlertActionTouched(tapGestureRecognizer: UITapGestureRecognizer) {
        print("imageView clicked")
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
            coverImageView.image = image
            flagOfImageView = true
        } else {
            secureImageView.image = image
            flagOfImageView = true
        }
        
        // pixel data 2진수로 표현
        let size = CGSize(width: 10, height: 10)
        let pixelData = image.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let position = CGPoint(x: 1, y: 1)
        let pixelInfo: Int = ((Int(size.width) * Int(position.y)) + Int(position.x)) * 4
        
        let r = String(Int(CGFloat(data[pixelInfo])), radix: 2)
        let g = String(Int(CGFloat(data[pixelInfo+1])), radix: 2)
        let b = String(Int(CGFloat(data[pixelInfo+2])), radix: 2)
        let a = String(Int(CGFloat(data[pixelInfo+3])), radix: 2)
        print("r: \(r)", "g: \(g)", "b: \(b)", "a: \(a)")
        
        dismiss(animated: true, completion: nil)
    }
}

//extension UIImage {
//    func getPixelColor(pos: CGPoint) -> UIColor {
//
//        let pixelData = CGDataProvider(data: CGImageGetDataProvider(self.CGImage!) as! CFData)
//        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//
//        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
//
//        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
//        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
//        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
//        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
//
//        return UIColor(red: r, green: g, blue: b, alpha: a)
//    }
//}

