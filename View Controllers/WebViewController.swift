//
//  WebViewController.swift
//  Networking
//
//  Created by Ivan Maslov on 19.08.2023.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // Variables to store course information
    var selectedCourse: String?
    var courseURL = ""
    
    // Outlets for UI elements
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title of the view controller to the selected course
        title = selectedCourse
        
        // Create a URL request for the course URL
        guard let url = URL(string: courseURL) else { return }
        let request = URLRequest(url: url)
        
        // Load the web page in the WKWebView
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
        // Add an observer to track estimated progress
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
    }
    
    // Observing changes in estimated progress
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // Show the progress view with animation
    private func showProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 1
        }, completion: nil)
    }
    
    // Hide the progress view with animation
    private func hideProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0
        }, completion: nil)
    }
    
}

extension WebViewController: WKNavigationDelegate {
    
    // Called when web page navigation starts
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressView()
    }
    
    // Called when web page navigation finishes successfully
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressView()
    }
    
    // Called when web page navigation fails with an error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressView()
    }
}
