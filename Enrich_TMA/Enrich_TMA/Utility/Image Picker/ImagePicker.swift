//
//  ImagePicker.swift
//  Enrich
//
//  Created by Harshal Patil on 27/05/19.
//  Copyright (c) 2019 e-Zest. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let SharedInstance = ImagePicker()

enum ImageEditMode {
    case `default`
    case custom
    case resizable
    case none
}

enum OpenMode {
    case gallery
    case camera
    case ask
    case none
}

class ImagePicker: NSObject {

    fileprivate var picker: UIImagePickerController = UIImagePickerController()
    fileprivate var imageEditMode: ImageEditMode = ImageEditMode.none
    fileprivate var resizableCropArea = false

    var cropRatio = CGSize(width: 1, height: 1)

    class var sharedInstance: ImagePicker {
        return SharedInstance
    }

    typealias ImageSelectionHandler = (_ imageSelected: Bool, _ image: UIImage?, _ imageUrl: URL?) -> Void

    fileprivate var completionHandler: ImageSelectionHandler!

    func pickImage(_ viewControl: UIViewController?, imageEditMode: ImageEditMode, openMode: OpenMode, completionHandler:@escaping ImageSelectionHandler) {

        self.imageEditMode = imageEditMode
        picker.allowsEditing = imageEditMode == ImageEditMode.default ? true : false
        resizableCropArea = imageEditMode == ImageEditMode.resizable ? true : false

        self.completionHandler = completionHandler

        if openMode == .camera {
            openCamera(viewControl)
        }
        else if openMode == .gallery {
            openGallery(viewControl)
        }
        else if openMode == .ask {

            let alertDisplay = UIAlertController(title: "", message: "Select Option", preferredStyle: .alert)

            let camera = UIAlertAction(title: "Camera", style: .default, handler: {(_: UIAlertAction!) -> Void in

                self.openCamera(viewControl)

            })

            let gallery = UIAlertAction(title: "Open Gallery", style: .default, handler: {(_: UIAlertAction!) -> Void in

                self.openGallery(viewControl)

            })

            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: {(_: UIAlertAction!) -> Void in
                print("Cancelled")

            })

            alertDisplay.addAction(camera)
            alertDisplay.addAction(gallery)
            alertDisplay.addAction(cancelAction)

            if let vc = viewControl {
                vc.present(alertDisplay, animated: true, completion: nil)
            }
            else {
                UIApplication.shared.keyWindow?.rootViewController?.present(alertDisplay, animated: true, completion: nil)
            }
        }
    }

//    func pickImage(_ completionHandler:@escaping ImageSelectionHandler){
//
//
////        self.completionHandler = completionHandler
//
//        imagePickerController.cropBlock = { image,url in
//            completionHandler(true, image, url as URL)
//        }
//
//        let app = UIApplication.shared.delegate as! AppDelegate
//        app.window?.rootViewController?.present(imagePickerController, animated: true, completion: nil)
//    }

    func openGallery(_ viewControl: UIViewController?) {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
          //  picker.allowsEditing = true
            picker.modalPresentationStyle = .custom
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.delegate = self

            if let vc = viewControl {
                vc.present(picker, animated: true, completion: nil)
            }
            else {
                UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true, completion: nil)
            }

        }
        else {
            let alertMessage = UIAlertController(title: "Service", message: "Service is not available", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertMessage.addAction(ok)

            if let vc = viewControl {
                vc.present(alertMessage, animated: true, completion: nil)
            }
            else {
                UIApplication.shared.keyWindow?.rootViewController?.present(alertMessage, animated: true, completion: nil)
            }
        }
    }

    func openCamera(_ viewControl: UIViewController?) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
           // picker.allowsEditing = true
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.modalPresentationStyle = .custom
            picker.cameraCaptureMode = .photo
            picker.delegate = self

            if let vc = viewControl {
                vc.present(picker, animated: true, completion: nil)
            }
            else {
                UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true, completion: nil)
            }
        }
        else {
            let alertMessage = UIAlertController(title: "Service", message: "Service is not available", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertMessage.addAction(ok)

            if let vc = viewControl {
                vc.present(alertMessage, animated: true, completion: nil)
            }
            else {
                UIApplication.shared.keyWindow?.rootViewController?.present(alertMessage, animated: true, completion: nil)
            }

        }

    }

}

extension ImagePicker: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

//        if imageEditMode == ImageEditMode.custom || imageEditMode == ImageEditMode.resizable {
//
//            let cropController = ImageCropViewController()
//            cropController.preferredContentSize = picker.preferredContentSize
//            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//            cropController.resizableCropArea = self.resizableCropArea
//            cropController.sourceImage = selectedImage
//            cropController.cropRatio = self.cropRatio;
//            cropController.delegate = self
//
//            if picker.sourceType == UIImagePickerController.SourceType.camera{
//                cropController.fromCamera = true
//            }else{
//                cropController.fromCamera = false
//            }
//            picker.pushViewController(cropController, animated: true)
//
//
//        }else{

        let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL

        let selectedImage: UIImage?

        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = possibleImage
        }
        else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = possibleImage
        }
        else {
            selectedImage = nil
        }

        self.completionHandler(true, selectedImage, imageUrl)
        picker.dismiss(animated: true, completion: nil)
        //}

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.completionHandler(false, nil, nil)

    }

}

//extension ImagePicker : ImageCropControllerDelegate {
//
//    func imageCropController(_ imageCropController: ImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage) {
//        self.completionHandler(true, croppedImage, nil)
//        imageCropController.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
//}

extension ImagePicker: UINavigationControllerDelegate {

}
