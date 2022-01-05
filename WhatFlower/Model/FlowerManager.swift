//
//  FlowerManager.swift
//  WhatFlower
//
//  Created by Micaella Morales on 1/4/22.
//

import Foundation
import CoreML
import Vision
import CoreImage
import Alamofire

protocol FlowerManagerDelegate {
    func didUpdateFlower(_ flowerManager: FlowerManager, flower: FlowerModel)
    func didFail(with error: Error)
}

struct FlowerManager {
    private let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    private var parameters: [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts|pageimages",
        "exintro" : "",
        "explaintext" : "",
        "indexpageids" : "",
        "redirects" : "1",
        "pithumbsize": "500"
    ]
    
    var delegate: FlowerManagerDelegate?
    
    //MARK: - CoreML and Vision integration
    
    func getClassification(flowerImage: CIImage, completion: @escaping (String) -> Void) {
        let configuration = MLModelConfiguration()
        guard let flowerClassifier = try? FlowerClassifier(configuration: configuration) else {
            fatalError("App failed to create a flower classifier model instance.")
        }
        guard let model = try? VNCoreMLModel(for: flowerClassifier.model) else {
            fatalError("App failed to create a VNCoreMLModel instance.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results?.first as? VNClassificationObservation else {
                fatalError("App failed to complete classification.")
            }
            completion(result.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    //MARK: - API request handling
    
    private func performRequest(for flowerName: String) {
        AF.request(wikipediaURl, method: .get, parameters: parameters).responseDecodable(of: FlowerData.self) { (response) in
            switch response.result {
            case .success(let flowerData):
                let query = flowerData.query
                let pageId = query.pageids[0]
                
                if let flowerPage = query.pages[pageId] {
                    let content = flowerPage.getContent()
                    let description = content.extract
                    let imageSource = content.thumbnail.source
                    let flower = FlowerModel(name: flowerName, description: description, imageSource: imageSource)
                    delegate?.didUpdateFlower(self, flower: flower)
                }
                
            case .failure(let error):
                delegate?.didFail(with: error)
            }
        }
    }
    
    mutating func setFlower(with flowerName: String) {
        parameters["titles"] = flowerName
        performRequest(for: flowerName)
    }
    
}
