//
//  ViewController.swift
//  WhatFlower
//
//  Created by Micaella Morales on 1/4/22.
//

import UIKit
import CoreML
import Vision

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
    
    func detect(flowerImage: CIImage) {
        let configuration = MLModelConfiguration()
        guard let flowerClassifier = try? FlowerClassifier(configuration: configuration) else {
            fatalError("App failed to create a flower classifier model instance.")
        }
        guard let model = try? VNCoreMLModel(for: flowerClassifier.model) else {
            fatalError("App failed to create a VNCoreMLModel instance.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, erroe) in
            guard let result = request.results?.first as? VNClassificationObservation else {
                fatalError("App failed to complete classification.")
            }
            
            self.title = result.identifier.capitalized
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.editedImage] as? UIImage {
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                fatalError("App failed to convert image to CIImage.")
            }
            detect(flowerImage: convertedCIImage)
            flowerImageView.image = userPickedImage
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
