//
//  WebsiteDescription.swift
//  Networking
//
//  Created by Ivan Maslov on 19.08.2023.
//

import Foundation

struct WebsiteDescription: Decodable {
    
    let websiteDescription: String?
    let websiteName: String?
    let courses: [Course]
}
