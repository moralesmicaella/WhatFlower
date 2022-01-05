//
//  ViewController.swift
//  WhatFlower
//
//  Created by Micaella Morales on 1/4/22.
//

import UIKit
import CoreML
import Vision
import Alamofire
import AlamofireImage

class ViewController: UIViewController {
    
    @IBOutlet var flowerImageView: UIImageView!
    @IBOutlet var flowerDescriptionLabel: UILabel!
    
    private let imagePicker = UIImagePickerController()
    var userPickedImage: UIImage?
    
    var flowerManager = FlowerManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowerManager.delegate = self
        imagePicker.delegate = self
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

//MARK: - Image picker delegate methods

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.editedImage] as? UIImage {
            self.userPickedImage = userPickedImage
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                fatalError("App failed to convert image to CIImage.")
            }
            
            flowerManager.getClassification(flowerImage: convertedCIImage) { (flowerName) in
                self.flowerManager.setFlower(with: flowerName)
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Flower manager delegate methods

extension ViewController: FlowerManagerDelegate {
    func didUpdateFlower(_ flowerManager: FlowerManager, flower: FlowerModel) {
        DispatchQueue.main.async {
            self.title = flower.name.capitalized
            self.flowerDescriptionLabel.text = flower.description
            if let flowerImageUrl = flower.imageUrl {
                self.flowerImageView.af.setImage(withURL: flowerImageUrl)
            }
        }
    }
    
    func didFail(with error: Error) {
        DispatchQueue.main.async {
            self.title = ""
            self.flowerDescriptionLabel.text = "No data found!"
            self.flowerImageView.image = self.userPickedImage
        }
        print(error)
    }
}
