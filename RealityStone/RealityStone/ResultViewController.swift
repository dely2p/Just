//
//  ResultViewController.swift
//  RealityStone
//
//  Created by dely on 2018. 10. 21..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit
import Metal
import MetalKit

class ResultViewController: UIViewController {
    @IBOutlet weak var mix: UIImageView!
    var realImage: UIImage!
    @IBOutlet weak var resultImageView: UIImageView!
    
    @IBAction func saveButton(_ sender: Any) {
        if let image = resultImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }
    
    @IBAction func changeButton(_ sender: Any) {
        queue.async { () -> Void in
            
            self.importTexture()
            
            self.applyFilter()
            
            let finalResult = self.image(from: self.outTexture)
            DispatchQueue.main.async {
                ImageInformation.shared.image = finalResult
                let color = finalResult.getPixelColorAtPoint(point: CGPoint(x: 0.0, y: 0.0), sourceView: self.mix)
                print("red: \(color.redValue*255)")
                print("green: \(color.greenValue*255)")
                print("blue: \(color.blueValue*255)")
                
            }
            if let resultViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") {
                self.present(resultViewController, animated: true, completion: nil)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        queue.async {
            self.setUpMetal()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultImageView.image = ImageInformation.shared.image
        
        let color = resultImageView.image!.getPixelColorAtPoint(point: CGPoint(x: 0.0, y: 0.0), sourceView: self.resultImageView)
        print("result red: \(color.redValue*0xff)")
        print("result green: \(color.greenValue*0xff)")
        print("result blue: \(color.blueValue*0xff)")
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
    var outTexture: MTLTexture!
    let bytesPerPixel: Int = 4
    
    /// A Metal compute pipeline state
    var pipelineState: MTLComputePipelineState?

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpMetal() {
        if let kernelFunction = defaultLibrary.makeFunction(name: "pixelate2") {
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
        guard let image = mix.image else {
            fatalError("Can't read image")
        }
        inTexture = texture(from: image)
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
        commandEncoder.setTexture(outTexture, index: 1)
        
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
    
}

extension UIImage {
    func getPixelColorAtPoint(point: CGPoint, sourceView: UIView) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        sourceView.layer.render(in: context!)
        let color: UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                     green: CGFloat(pixel[1])/255.0,
                                     blue: CGFloat(pixel[2])/255.0,
                                     alpha: CGFloat(pixel[3])/255.0)
//        pixel.deallocate(capacity: 4)
        return color
    }
}

extension UIColor {
    
    var redValue: CGFloat{
        return cgColor.components! [0]
    }
    
    var greenValue: CGFloat{
        return cgColor.components! [1]
    }
    
    var blueValue: CGFloat{
        return cgColor.components! [2]
    }
    
    var alphaValue: CGFloat{
        return cgColor.components! [3]
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

