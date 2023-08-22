//
//  ImageViewController.swift
//  Networking
//
//  Created by Ivan Maslov on 17.08.2023.
//

import UIKit

class ImageViewController: UIViewController {
    
    private let url = "https://i.ibb.co/P52SMkm/i-OS-17-Light-by-i-SWUpdates.png"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        fetchImage()
        
    }
    
    func fetchImage() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        NetworkManager.downloadImage(url: url) { image in
            
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
}

