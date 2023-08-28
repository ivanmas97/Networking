//
//  MainCollectionViewController.swift
//  Networking
//
//  Created by Ivan Maslov on 22.08.2023.
//

import UIKit
import UserNotifications

// Enum to define various actions
enum Actions: String, CaseIterable {
    
    case downloadImage = "Download Image"
    case get = "GET"
    case post = "POST"
    case swiftbookCourses = "Swiftbook Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download File"
}

// Constants
private let reuseIdentifier = "Cell"   // Reuse identifier for collection view cells
private let url = "https://jsonplaceholder.typicode.com/posts"  // URL for GET and POST requests
private let uploadImage = "https://api.imgur.com/3/image"   // URL for uploading images

class MainCollectionViewController: UICollectionViewController {
    
    let actions = Actions.allCases   // Array of available actions
    private var alert: UIAlertController!   // Alert controller for showing download progress
    private let dataProvider = DataProvider()   // Data provider for handling downloads
    private var filePath: String?   // Path to the downloaded file
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set collection view delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register for user notifications
        registerForNotification()
        
        // Callback for handling finished downloads
        dataProvider.fileLocation = { (location) in
            
            // Save file for future use
            print("Download finished: \(location.absoluteString)")
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: false)
            self.postNotification()
        }
    }
    
    // Function to show a download progress alert
    private func showAlert() {
        
        alert = UIAlertController(title: "Downloading...",
                                  message: "0%",
                                  preferredStyle: .alert)
        
        // Set height constraint for the alert view
        let height = NSLayoutConstraint(item: alert.view!,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0,
                                        constant: 170)
        alert.view.addConstraint(height)
        
        // Create cancel action to stop the download
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
            self.dataProvider.stopDownload()
        }
        
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            
            // Create and configure an activity indicator
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: (self.alert.view.frame.width / 2) - size.width / 2,
                                y: (self.alert.view.frame.height / 2) - size.height / 2)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            // Create and configure a progress view
            let progressView = UIProgressView(frame: CGRect(x: 0,
                                                            y: self.alert.view.frame.height - 44,
                                                            width: self.alert.view.frame.width,
                                                            height: 1))
            progressView.tintColor = .blue
            
            // Update the progress as the download proceeds
            self.dataProvider.onProgress = { (progress) in
                progressView.progress = progress
                self.alert.message = String(Int(progress * 100)) + "%"
            }
            
            // Add the activity indicator and progress view to the alert view
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return actions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.label.text = actions[indexPath.row].rawValue
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = actions[indexPath.row]
        
        switch action {
        case .downloadImage:
            performSegue(withIdentifier: "ShowImage", sender: self)
        case .get:
            NetworkManager.getRequest(url: url)
        case .post:
            NetworkManager.postRequest(url: url)
        case .swiftbookCourses:
            performSegue(withIdentifier: "ShowCourses", sender: self)
        case .uploadImage:
            NetworkManager.uploadImage(url: uploadImage)
        case .downloadFile:
            
            // Start file download and show progress alert
            dataProvider.startDownload()
            showAlert()
        }
    }
}

// MARK: - Notifications

extension MainCollectionViewController {
    
    // Request authorization for user notifications
    private func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            
        }
    }
    
    // Post a user notification upon download completion
    private func postNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Download complete!"
        content.body = "Your background transfer has completed. File path: \(filePath!)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
