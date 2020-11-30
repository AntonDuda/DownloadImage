//
//  ImageLoadCell.swift
//  DownloadImage
//
//  Created by Anton on 25.11.2020.
//

import UIKit

protocol ImageLoadCellDelegate {
    func buttonCancelTapped(_ cell: ImageLoadCell)
    func buttonDownloadTapped(_ cell: ImageLoadCell)
    func buttonPauseTapped(_ cell: ImageLoadCell)
    func buttonResumeTapped(_ cell: ImageLoadCell)
}

class ImageLoadCell: UITableViewCell {
    
    // MARK: < Constants >
    
    static let identifier = "ImageLoadCell"
    
    // MARK: < IBOutlets >
    
    @IBOutlet weak var imageDownloadedImage: UIImageView!
    @IBOutlet weak var labelImageName: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var buttonPauseResume: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonDownload: UIButton!
    
    // MARK: < Variables And Properties >
    
    var delegate: ImageLoadCellDelegate?
    
    // MARK: < IBActions >
    
    @IBAction func buttonPause(_ sender: Any) {
        if(buttonPauseResume.titleLabel?.text == "Pause") {
            delegate?.buttonPauseTapped(self)
        } else {
            delegate?.buttonResumeTapped(self)
        }
    }
    
    @IBAction func buttonCancel(_ sender: Any) {
        delegate?.buttonCancelTapped(self)
    }
    
    @IBAction func buttonDownload(_ sender: Any) {
        delegate?.buttonDownloadTapped(self)
    }
    
    // MARK: < Internal Methods >
    
    func configure(image: Image, download: Download?) {
        labelImageName.text = image.id
        
        if let data = try? Data(contentsOf: image.urls.small),
           let image = UIImage(data: data) {
            imageDownloadedImage.image = image
        }
        var showControls = false
        if let download = download, download.localImageURL == nil {
            progressView.progress = download.progress
            let title = download.isDownloading ? "Pause" : "Resume"
            buttonPauseResume.setTitle(title, for: .normal)
            labelProgress.text = download.isDownloading ? "Downloading..." : "Paused"
            showControls = true
                        
        }
        showLoadingControls(showControls)
        
        let isDownloaded = download?.localImageURL != nil
        buttonDownload.isHidden = isDownloaded || showControls
}
    func updateDisplay(progress: Float, totalSize : String) {
      progressView.progress = progress
      labelProgress.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    // MARK: < Private methods >
    
    private func showLoadingControls(_ show: Bool) {
        buttonCancel.isHidden = !show
        progressView.isHidden = !show
        labelProgress.isHidden = !show
        buttonPauseResume.isHidden = !show
    }
}
