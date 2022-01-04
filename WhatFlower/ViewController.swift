//
//  ViewController.swift
//  WhatFlower
//
//  Created by Micaella Morales on 1/4/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var flowerImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            flowerImageView.image = image
            print("set image")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
