//
//  Download.swift
//  DownloadImage
//
//  Created by Anton on 26.11.2020.
//

import Foundation

class Download {
  
    // MARK: < Vars >
  
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var localImageURL: URL?
    var task: URLSessionDownloadTask?
    var image: Image
    
    var downloaded = false
    
    // MARK: < Initialization >
  
    init(image: Image) {
        self.image = image
    }
}
