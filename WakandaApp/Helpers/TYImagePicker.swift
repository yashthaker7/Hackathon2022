//
//  TYImagePicker.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 15/06/21.
//

import UIKit
import AVFoundation
import Photos

protocol TYImagePickerDelegate: AnyObject {
    func imagePicker(_ imagePicker: TYImagePicker, selectedImage: UIImage?)
    func imagePicker(_ imagePicker: TYImagePicker, videoURL: URL)
    func cancelButtonTapped(on imagePicker: TYImagePicker)
}

class TYImagePicker: NSObject {

    private weak var parentController: UIViewController!
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    weak var delegate: TYImagePickerDelegate?
    
    func presentActionSheet(title: String? = nil, message: String? = nil, parent viewController: UIViewController) {
        /*
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alertVC.setTint(color: .black)
        alertVC.setTitle(font: UIFont(appFont: .PoppinsMedium, size: 18), color: .black)
        alertVC.setMessage(font: UIFont(appFont: .PoppinsRegular, size: 15), color: .black)
        alertVC.setSourceViewForIpad(viewController.view)
        alertVC.popoverPresentationController?.permittedArrowDirections = []
        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                self.cameraAccessRequest()
            }
            alertVC.addAction(cameraAction)
        }
        
        let photoGelleryAction = UIAlertAction(title: "Photo Gallery", style: .default) { action in
            self.photoGalleryAccessRequest()
        }
        alertVC.addAction(photoGelleryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertVC.addAction(cancelAction)
        
        self.parentController = viewController
        parentController.present(alertVC, animated: true, completion: nil)
        */
        self.parentController = viewController
        photoGalleryAccessRequest()
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        parentController.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK:- Get access to camera or photo library

extension TYImagePicker {

    private func showAlert(source: UIImagePickerController.SourceType) {
        let targetName = source == .camera ? "camera" : "photo gallery"
        let title = "\"\(UIApplication.appName)\" would like to use \(targetName)."
        let message = "\nGrant permission to\n\"\(UIApplication.appName)\" to access \(targetName)."
        AlertManager.systemAlert(title: title, message: message, negativeTitle: "Cancel", positiveTitle: "Open Settings", parentController: parentController) {
            // negativeActionHandler
        } positiveActionHandler: {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else {
                return
            }
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
        /*
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in })
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else {
                return
            }
            UIApplication.shared.open(settingsUrl, options: [:]) { _ in }
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(settingsAction)
        parentController?.present(alertVC, animated: true, completion: nil)
        */
    }

    private func cameraAccessRequest() {
        if delegate == nil {
            return
        }
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            presentImagePicker(sourceType: .camera)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    guard granted else {
                        self.showAlert(source: .camera)
                        return
                    }
                    self.presentImagePicker(sourceType: .camera)
                }
            }
        }
    }

    private func photoGalleryAccessRequest() {
        PHPhotoLibrary.requestAuthorization { result in
            DispatchQueue.main.async {
                guard result == .authorized else {
                    self.showAlert(source: .photoLibrary)
                    return
                }
                self.presentImagePicker(sourceType: .photoLibrary)
            }
        }
    }
}

// MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension TYImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage?
        if let image = info[.editedImage] as? UIImage {
            newImage = image
        } else if let image = info[.originalImage] as? UIImage {
            newImage = image
        } else if let videoURL = info[.mediaURL] as? URL {
            picker.dismiss(animated: true) {
                self.delegate?.imagePicker(self, videoURL: videoURL)
            }
            return
        }
        newImage = newImage?.updateImageOrientionUpSide()
        
        if let compressImageData = newImage?.jpegData(compressionQuality: 0) {
            newImage = UIImage(data: compressImageData)
        }
        
        picker.dismiss(animated: true) {
            self.delegate?.imagePicker(self, selectedImage: newImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.delegate?.cancelButtonTapped(on: self)
        }
    }
}

extension UIImage {
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}
