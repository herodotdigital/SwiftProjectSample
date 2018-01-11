//
//  ImagePicker.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 10.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

protocol ImagePickerDelegate:class {
    
    func didFinishWithImage(_ image: UIImage?)
    
}

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate {
    
    var picker = UIImagePickerController()
    var popover: UIPopoverController?
    weak var delegate: ImagePickerDelegate?
    
    func configureImagePicker(_ viewController: UIViewController) {
        let alert: UIAlertController=UIAlertController(title: LocalizedString("Choose Image"), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: LocalizedString("Camera"), style: UIAlertActionStyle.default) {
            UIAlertAction in self.openCamera(viewController)
        }
        let galleryAction = UIAlertAction(title: LocalizedString("Gallery"), style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openGallery(viewController)
        }
        let cancelAction = UIAlertAction(title: LocalizedString("Cancel"), style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        presentController(alert, viewController: viewController)
    }
    
    func presentController(_ alert: UIAlertController, viewController: UIViewController) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            viewController.present(alert, animated: true, completion: nil)
        } else {
            popover = UIPopoverController(contentViewController: alert)
            popover!.present(from: viewController.view.frame, in: viewController.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func openCamera(_ viewController: UIViewController) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            viewController.present(picker, animated: true, completion: nil)
        } else {
            openGallery(viewController)
        }
    }
    
    func openGallery(_ viewController: UIViewController) {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone {
            viewController.present(picker, animated: true, completion: nil)
        } else {
            popover = UIPopoverController(contentViewController: picker)
            popover?.present(from: viewController.view.frame, in: viewController.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            assert(false, "Cannot receive image")
            delegate?.didFinishWithImage(UIImage())
            return
        }
        
        delegate?.didFinishWithImage(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
