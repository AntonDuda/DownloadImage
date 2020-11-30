//
//  ListImageViewController.swift
//  DownloadImage
//
//  Created by Anton on 25.11.2020.
//

import UIKit

class ListImageViewController: UIViewController, APIServiceDelegate {
    
    // MARK: < Vars >
    
    private let apiService = APIService()
    private var listImages: [Image] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: < Outlets >
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: < Lifecycle >
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        apiService.delegate = self
        apiService.images { [weak self] (images) in
            self?.listImages = images
        }
        
        tableView.tableFooterView = UIView()

    }
    
    // MARK: < Prepare for Segue >
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedPath = tableView.indexPathForSelectedRow else { return }
        let image = listImages[selectedPath.row]
        if let target = segue.destination as? ImageViewController,
           let imageURL = apiService.download(for: image)?.localImageURL {
            target.setup(imageURL: imageURL)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let selectedPath = tableView.indexPathForSelectedRow else { return false }
        let image = listImages[selectedPath.row]
        let download = apiService.download(for: image)
        return download?.localImageURL != nil
    }
    
    // MARK: < Public methods >
    
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
    // MARK: < APIService Delegate >
    
    func didUpdate(progress: Float, totalSize : String, image: Image) {
        guard
            let row = listImages.firstIndex (where: { $0.id == image.id }),
            let cell = tableView.cellForRow(at: .init(row: row, section: 0)) as? ImageLoadCell
        else { return }
        
        cell.updateDisplay(progress: progress, totalSize: totalSize)
    }
    
    func didFinishLoading(_ image: Image) {
        guard let row = listImages.firstIndex (where: { $0.id == image.id }) else { return }
        reload(row)
    }
    
}


    // MARK: < Table View Data Source >

extension ListImageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ImageLoadCell = tableView.dequeueReusableCell(withIdentifier: ImageLoadCell.identifier, for: indexPath) as? ImageLoadCell else {
            fatalError("ImageLoadCell must be registered")
        }
        
        let image = listImages[indexPath.row]
        let download = apiService.download(for: image)
        
        cell.configure(image: image, download: download)
        cell.delegate = self
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listImages.count
    }
    
}


    // MARK: < Table View Delegate >

extension ListImageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

    // MARK: < Image Load Cell Delegate >

extension ListImageViewController: ImageLoadCellDelegate {
    
    func buttonCancelTapped(_ cell: ImageLoadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = listImages[indexPath.row]
            apiService.cancelDownload(image)
            reload(indexPath.row)
        }
    }
    
    func buttonDownloadTapped(_ cell: ImageLoadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = listImages[indexPath.row]
            apiService.startDownload(image)
            reload(indexPath.row)
        }
    }
    
    func buttonPauseTapped(_ cell: ImageLoadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = listImages[indexPath.row]
            apiService.pauseDownload(image)
            reload(indexPath.row)
        }
    }
    
    func buttonResumeTapped(_ cell: ImageLoadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let image = listImages[indexPath.row]
            apiService.resumeDownload(image)
            reload(indexPath.row)
        }
    }
}

