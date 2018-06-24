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

    @IBOutlet weak var sliderBar: UISlider!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var secureImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    
    private var imagePicker = UIImagePickerController()
    private var flagOfImageView = false
    private var coverImagePixel: [RGBData]!
    private var secureImagePixel: [RGBData]!
    let rgbPixelMaker = RGBPixelMaker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coverTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertActionTouched(tapGestureRecognizer:)))
        let secureTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertActionTouched(tapGestureRecognizer:)))
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(coverTapGesture)
        secureImageView.isUserInteractionEnabled = true
        secureImageView.addGestureRecognizer(secureTapGesture)
        imagePicker.delegate = self
        sliderBar.maximumValue = 8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // slider
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print(Int(sender.value))
        let bit = Int(sender.value)
        
        // 픽셀 별로 해당 비트만큼 치환
        let resultImage = rgbPixelMaker.makebitMixing(imageA: coverImagePixel, imageB: secureImagePixel, bit: bit)
        //rgbPixelMaker.printImagefirstByte(coverImagePixel)
        //rgbPixelMaker.printImagefirstByte(secureImagePixel)
        // coverimageView에 result 넣기
        resultImageView.image = rgbPixelMaker.makeMixingImage(rgbData: resultImage, coverImage: coverImageView.image!)
        //rgbPixelMaker.printImagefirstByte(resultImage)
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
    // imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        if !flagOfImageView {
            coverImageView.image = image
            
        } else {
            secureImageView.image = image
            
        }
        dismiss(animated: true, completion: imagePickerDidEnd)
    }
    
    func imagePickerDidEnd() {
        if !flagOfImageView {
            coverImagePixel = rgbPixelMaker.makeBinaryPixel(image: coverImageView.image!)
            flagOfImageView = true
            print("cover")
        } else {
            secureImagePixel = rgbPixelMaker.makeBinaryPixel(image: secureImageView.image!)
            flagOfImageView = false
            print("secure")
        }
    }

}
