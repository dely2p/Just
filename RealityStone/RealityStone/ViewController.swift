//
//  ViewController.swift
//  Just
//
//  Created by dely on 2018. 5. 16..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit
import Metal
import MetalKit

class ViewController: UIViewController {

    var pixelSize: UInt = 60
    var flagOfImageView = false
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var secureImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    var cover: UIImage!
    var secure: UIImage!
    
    private var imagePicker = UIImagePickerController()
    @IBAction func changeButton(_ sender: Any) {
        
        queue.async { () -> Void in
            
            self.importTexture()
            
            self.applyFilter()
            
            let finalResult = self.image(from: self.outTexture)
            DispatchQueue.main.async {
                self.resultImageView.image = finalResult
            }
            
        }
    }
    
    /// The queue to process Metal
    let queue = DispatchQueue(label: "dely")
    
    /// A Metal device
    lazy var device: MTLDevice! = MTLCreateSystemDefaultDevice()
    
    /// A Metal library
    lazy var defaultLibrary: MTLLibrary! = {
        self.device.makeDefaultLibrary()
    }()
    
    /// A Metal command queue
    lazy var commandQueue: MTLCommandQueue! = {
        NSLog("\(self.device.name)")
        return self.device.makeCommandQueue()
    }()
    
    var inTexture: MTLTexture!
    var inTexture2: MTLTexture!
    var outTexture: MTLTexture!
    let bytesPerPixel: Int = 4
    
    /// A Metal compute pipeline state
    var pipelineState: MTLComputePipelineState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coverTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertActionTouched(tapGestureRecognizer:)))
        let secureTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertActionTouched(tapGestureRecognizer:)))
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(coverTapGesture)
        secureImageView.isUserInteractionEnabled = true
        secureImageView.addGestureRecognizer(secureTapGesture)
        imagePicker.delegate = self
        
        queue.async {
            self.setUpMetal()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpMetal() {
        if let kernelFunction = defaultLibrary.makeFunction(name: "pixelate") {
            do {
                pipelineState = try device.makeComputePipelineState(function: kernelFunction)
                print("pipeline init")
            }
            catch {
                fatalError("Impossible to setup Metal")
            }
        }
    }
    
    let threadGroupCount = MTLSizeMake(16, 16, 1)
    
    lazy var threadGroups: MTLSize = {
        MTLSizeMake(Int(self.inTexture.width) / self.threadGroupCount.width, Int(self.inTexture.height) / self.threadGroupCount.height, 1)
    }()
    
    func importTexture() {
        guard let image = cover else {
            fatalError("Can't read image")
        }
        guard let image2 = secure else {
            fatalError("Can't read image")
        }
        inTexture = texture(from: image)
        inTexture2 = texture(from: image2)
    }
    
    func applyFilter() {
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        guard let pState = pipelineState else {
            print("is pipelinestate nil??")
            return
        }
        
        commandEncoder.setComputePipelineState(pState)
        commandEncoder.setTexture(inTexture, index: 0)
        commandEncoder.setTexture(inTexture2, index: 1)
        commandEncoder.setTexture(outTexture, index: 2)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func texture(from image: UIImage) -> MTLTexture {
        
        guard let cgImage = image.cgImage else {
            fatalError("Can't open image \(image)")
        }
        
        let textureLoader = MTKTextureLoader(device: self.device)
        do {
            let textureOut = try textureLoader.newTexture(cgImage: cgImage, options: [:])
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: textureOut.pixelFormat, width: textureOut.width, height: textureOut.height, mipmapped: false)
            textureDescriptor.usage = [.shaderRead, .shaderWrite]
            outTexture = self.device.makeTexture(descriptor: textureDescriptor)
            return textureOut
        }
        catch {
            fatalError("Can't load texture")
        }
    }
    
    func image(from texture: MTLTexture) -> UIImage {
        
        let imageByteCount = texture.width * texture.height * bytesPerPixel
        let bytesPerRow = texture.width * bytesPerPixel
        var src = [UInt8](repeating: 0, count: Int(imageByteCount))
        
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        texture.getBytes(&src, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
//        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            .union(.byteOrder32Little)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        let context = CGContext(data: &src,
                                width: texture.width,
                                height: texture.height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
        
        let dstImageFilter = context?.makeImage()
        
        return UIImage(cgImage: dstImageFilter!, scale: 0.0, orientation: UIImage.Orientation.up)
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
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // AlertAction에서 Camera 눌렀을 때
    func openCameraTouched() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("not Available")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else {
            return
        }
        if !flagOfImageView {
            coverImageView.image = image
            cover = image

        } else {
            secureImageView.image = image
            secure = image

        }
        dismiss(animated: true, completion: imagePickerDidEnd)
    }
    
    func imagePickerDidEnd() {
        if !flagOfImageView {
            flagOfImageView = true
            print("cover")
        } else {
            flagOfImageView = false
            print("secure")
        }
    }

}

extension UIImage {
    func renderResizedImage (newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let image = renderer.image { (context) in
            self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        }
        return image
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

