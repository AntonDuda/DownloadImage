//
//  ImageViewController.swift
//  DownloadImage
//
//  Created by Anton on 30.11.2020.
//

import UIKit

class ImageViewController: UIViewController {
    
    // MARK: < Outlets >
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: < Vars >
    
    private var image: UIImage?
    
    // MARK: < Public methods >
    
    func setup(imageURL: URL) {
        guard let data = try? Data(contentsOf: imageURL) else {
            return
        }
        self.image = UIImage(data: data)
    }
    
    // MARK: < Lifecycle >
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = image
    }
}
