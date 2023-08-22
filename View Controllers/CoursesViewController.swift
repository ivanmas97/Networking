//
//  CoursesViewController.swift
//  Networking
//
//  Created by Ivan Maslov on 17.08.2023.
//

import UIKit
import WebKit

class CoursesViewController: UIViewController {
    
    private var courses = [Course]()
    private var courseName: String?
    private var courseUrl: String?
    private var url = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        viewActivityIndicator.isHidden = false
        viewActivityIndicator.hidesWhenStopped = true

        fetchData()
    }
    
    // Fetching data from URL
    
    func fetchData() {
        
        NetworkManager.fetchData(url: url) { courses in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Cell configuration
    
    private func configureCell(cell: TableViewCell, for indexPath: IndexPath) {
        
        let course = courses[indexPath.row]
        cell.courseNameLabel.text = course.name
        
        if let numberOfLessons = course.numberOfLessons {
            cell.numberOfLessonsLabel.text = "Number of lessons: \(numberOfLessons)"
        }
        
        if let numberOfTests = course.numberOfTests {
            cell.numberOfTestsLabel.text = "Number of tests: \(numberOfTests)"
        }
        
        DispatchQueue.global().async {
            guard let imageUrl = URL(string: course.imageUrl!) else { return }
            guard let imageData = try? Data(contentsOf: imageUrl) else { return }
            
            DispatchQueue.main.async {
                cell.courseImage.image = UIImage(data: imageData)

            }
        }
    }
    
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         let webViewController = segue.destination as! WebViewController
         webViewController.selectedCourse = courseName
         
         if let url = courseUrl {
             webViewController.courseURL = url
         }
     }
     
}

// MARK: - Table view Data Source

extension CoursesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        
        configureCell(cell: cell, for: indexPath)
        
        return cell
    }
}

// MARK: - Table view Delegate

extension CoursesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[indexPath.row]
        
        courseName = course.name
        courseUrl = course.link
        
        performSegue(withIdentifier: "Description", sender: self)
    }
}
