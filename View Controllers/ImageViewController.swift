//
//  ImageViewController.swift
//  Networking
//
//  Created by Ivan Maslov on 17.08.2023.
//

import UIKit

// URL for the image to be fetched
private let url = "https://i.ibb.co/P52SMkm/i-OS-17-Light-by-i-SWUpdates.png"

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the activity indicator initially
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        // Fetch and display the image
        fetchImage()
    }
    
    // Function to fetch and display the image
    func fetchImage() {
        
        // Show the activity indicator while fetching the image
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Use NetworkManager to download the image
        NetworkManager.downloadImage(url: url) { image in
            
            // Stop the activity indicator and set the fetched image
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
}
