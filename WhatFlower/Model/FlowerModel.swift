//
//  FlowerModel.swift
//  WhatFlower
//
//  Created by Micaella Morales on 1/4/22.
//

import Foundation

struct FlowerModel {
    let name: String
    let description: String
    let imageSource: String?
    
    var imageUrl: URL? {
        if let imageSource = imageSource {
            return URL(string: imageSource)
        }
        return nil
    }
}
