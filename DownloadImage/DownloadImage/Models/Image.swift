//
//  Image.swift
//  DownloadImage
//
//  Created by Anton on 26.11.2020.
//

import Foundation

struct Image: Codable {
    
    // MARK: < Variables >
    
    let id: String
    let description: String?
    let urls: Urls
    
}

struct Urls: Codable {
    let full: URL
    let small: URL
}
