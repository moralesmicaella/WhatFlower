//
//  FlowerModel.swift
//  WhatFlower
//
//  Created by Micaella Morales on 1/4/22.
//

import Foundation

struct FlowerData: Codable {
    let query: Query
}

struct Query: Codable {
    let pageids: [String]
    let pages: [String: Page]
}

enum Page: Codable {
    case flowerPage(Content)
    
    init(from decoder: Decoder) throws {
        do {
            let keyedContainer = try decoder.container(keyedBy: Content.CodingKeys.self)
            let extract = try keyedContainer.decode(String.self, forKey: .extract)
            let thumbnail = try keyedContainer.decode(ImageInfo.self, forKey: .thumbnail)
            self = .flowerPage(Content(extract: extract, thumbnail: thumbnail))
            return
        } catch {
            print(error)
        }
        throw DecodingError.corruptedData
    }
    
    func getContent() -> Content {
        switch self {
        case .flowerPage(let content):
            return content
        }
    }
}

struct Content: Codable {
    let extract: String
    let thumbnail: ImageInfo
    
    enum CodingKeys: String, CodingKey {
        case extract, thumbnail
    }
}

struct ImageInfo: Codable {
    let source: String
}

enum DecodingError: Error {
    case corruptedData
}
