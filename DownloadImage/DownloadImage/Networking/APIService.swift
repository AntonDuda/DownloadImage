//
//  APIService.swift
//  DownloadImage
//
//  Created by Anton on 26.11.2020.
//

import Foundation

protocol APIServiceDelegate: class {
    func didFinishLoading(_ image: Image)
    func didUpdate(progress: Float, totalSize : String, image: Image)
}

class APIService: NSObject {
    
    // MARK: < Vars >
  
    weak var delegate: APIServiceDelegate?
    private(set) var downloads = [URL: Download]()

    private let apiKey = "Ug5nxKao3MwWhIFmb0ej19YRGA4MXngebnSqf4nr9d8"
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private lazy var session = URLSession(configuration: .background(withIdentifier: "ImageLoading"), delegate: self, delegateQueue: nil)
    
    // MARK: < Public methods >
    
    func download(for image: Image) -> Download? {
        return downloads[image.urls.full]
    }
    
    func cancelDownload(_ image: Image) {
        guard let download = download(for: image) else {
            return
        }
        download.task?.cancel()
        downloads[image.urls.full] = nil
    }
  
    func pauseDownload(_ image: Image) {
        guard let download = download(for: image), download.isDownloading else {
            return
        }
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        download.isDownloading = false
    }
  
    func resumeDownload(_ image: Image) {
        guard let download = download(for: image) else {
            return
        }
    
        if let resumeData = download.resumeData {
            download.task = session.downloadTask(withResumeData: resumeData)
        } else {
            download.task = session.downloadTask(with: download.image.urls.full)
        }
    
        download.task?.resume()
        download.isDownloading = true
    }
    
    func startDownload(_ image: Image) {
        let download = Download(image: image)
        download.task = session.downloadTask(with: image.urls.full)
        download.task?.resume()
        download.isDownloading = true
        downloads[image.urls.full] = download
    }
    
    func images(completion: @escaping ([Image]) -> Void) {
        let urlString = "https://api.unsplash.com/photos/random?count=15"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
            guard let res = data else {
                completion([])
                return
            }
        
            let response = try? JSONDecoder().decode([Image].self, from: res)
            DispatchQueue.main.async {
                completion(response ?? [])
            }
        }
        
        task.resume()
    }
    
    // MARK: < Private methods >
    
    private func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
}
    // MARK: < URLSession Download Delegate >

extension APIService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard
            let sourceURL = downloadTask.originalRequest?.url,
            let download = downloads[sourceURL] else { return }
        
        let destinationURL = localFilePath(for: sourceURL)

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            downloads[sourceURL]?.localImageURL = destinationURL
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.delegate?.didFinishLoading(download.image)
        }
        
    }
  
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard
            let url = downloadTask.originalRequest?.url,
            let download = downloads[url] else { return }
        
        download.progress
            = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        let totalSize = ByteCountFormatter.string(
            fromByteCount: totalBytesExpectedToWrite,
            countStyle: .file
        )
        
        DispatchQueue.main.async {
            self.delegate?.didUpdate(progress: download.progress, totalSize: totalSize, image: download.image)
        }
    }
}
