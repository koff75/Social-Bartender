//
//  PrendrePhotoHelper.swift
//  Social Bartender
//
//  Created by nico on 29/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit

// This means that any function that wants to be the callback of the PhotoTakingHelper needs to have exactly this signature
typealias PhotoTakingHelperCallback = UIImage? -> Void

class PrendrePhotoHelper : NSObject {
    
    // View controller on which AlertViewController and UIImagePickerController are presented
    // Weak car il n'a pas sa propre référérence vers ViewController
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        typeDeSelectionPhoto()
    }
    
    func typeDeSelectionPhoto() {
        // Menu pour savoir si l'utilisateur veux prendre une photo ou sélectionner dans sa bibliothèque
        let alertController = UIAlertController(title: nil, message: "Comment voulez-vous prendre la photo ?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Bibliothèque", style: .Default) { (action) in
            self.afficherImagePickerController(.PhotoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        // Affiche seulement la caméra si elle est disponible
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = UIAlertAction(title: "Appareil Photo", style: .Default) { (action) in
                // Appel de la méthode afficherImagePickerController avec le paramètre camera
                self.afficherImagePickerController(.Camera)
            }
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Paramètre sourceType correspond au choix de l'utilisateur (caméra ou bibliothèque)
    // Va afficher la popup correspondante suivant le type choisit
    func afficherImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
}


// Permet de gérer les actions de l'utilisateur quand il sélectionne une photo
// Si cette méthode n'existé pas, si l'utilisateur sélectionne une photo ou clique sur annuler, le fenêtre ne fera rien
extension PrendrePhotoHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Appelée quand une image est sélectionnée
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        callback(image)
    }
    // Appelée quand le bouton 'annuler' est appuyé
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}