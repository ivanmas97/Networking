//
//  DataProvider.swift
//  Networking
//
//  Created by Ivan Maslov on 26.08.2023.
//

import UIKit

// URL for the download
private let url = "https://speedtest.selectel.ru/10MB"

class DataProvider: NSObject {
    
    private var downloadTask: URLSessionDownloadTask!
    var fileLocation: ((URL) -> Void)?   // Callback for reporting file location
    var onProgress: ((Float) -> Void)?    // Callback for reporting download progress
    
    override init() {
        super.init()
        print("DataProvider initialized")
    }
    
    // Lazily initialize a background URLSession with specific configurations
    private lazy var bgSession: URLSession = {
        
        let config = URLSessionConfiguration.background(withIdentifier: "ru.ivanmas97.Networking")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // Start a download task
    func startDownload() {
        if let url = URL(string: url) {
            downloadTask = bgSession.downloadTask(with: url)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            downloadTask.countOfBytesClientExpectsToSend = 512
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024
            downloadTask.resume()
            
            if let error = downloadTask.error {
                print("Error during download: \(error.localizedDescription)")
            }
        }
    }
    
    // Cancel the download task
    func stopDownload() {
        downloadTask.cancel()
    }
    
    deinit {
        print("DataProvider deinitialized")
    }
}

extension DataProvider: URLSessionDelegate {
    
    // Handle the completion of background session events
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        print("Session events finished")
        
        DispatchQueue.main.async {
            guard
                let appDelegate = URLSession.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.bgSessionCompletionHandler
            else { return }
            
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()
        }
    }
}

extension DataProvider: URLSessionDownloadDelegate {
    
    // Handle the completion of a download task, including errors
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Session completed with error: \(error.localizedDescription)")
        } else {
            print("Session completed successfully")
        }
    }
    
    // Handle the completion of a download task and provide the file location
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("Did finish downloading: \(location.absoluteString)")
        
        DispatchQueue.main.async {
            self.fileLocation?(location)
        }
    }
    
    // Report download progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("Download progress: \(progress)")
        
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
}
