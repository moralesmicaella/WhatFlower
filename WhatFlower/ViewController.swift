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
            self.requestInfo(flowerName: result.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func requestInfo(flowerName: String) {
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize": "500"
        ]
        
        AF.request(wikipediaURl, method: .get, parameters: parameters).responseDecodable(of: FlowerData.self) { (response) in
            switch response.result {
            case .success(let flowerData):
                let query = flowerData.query
                let pageId = query.pageids[0]
                if let flowerPage = query.pages[pageId] {
                    let content = flowerPage.getContent()
                    DispatchQueue.main.async {
                        if let flowerImageUrl = URL(string: content.thumbnail.source) {
                            self.flowerImageView.af.setImage(withURL: flowerImageUrl)
                        }
                        self.flowerDescriptionLabel.text = content.extract
                    }
                }
            case .failure(let error):
                print(error)
                self.flowerImageView.image = self.userPickedImage
                self.flowerDescriptionLabel.text = "No data found!"
                
            }
        }

    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.editedImage] as? UIImage {
            self.userPickedImage = userPickedImage
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                fatalError("App failed to convert image to CIImage.")
            }
            detect(flowerImage: convertedCIImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
