//
//  ClassPhoto.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/15/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import Foundation

class FlickrPhoto: Codable {
    let title: String
    let remoteURL: URL?
    let photoID: String
    let dateTaken: Date
    
    init(title: String, remoteURL: URL, photoID: String, dateTaken: Date){
        self.title = title
        self.remoteURL = remoteURL
        self.photoID = photoID
        self.dateTaken = dateTaken
    }
    
    // this is used bc the keys in the json are not descriptive and we need them to match our property names
    enum CodingKeys: String, CodingKey {
        case title
        case remoteURL = "url_z"
        case photoID = "id"
        case dateTaken = "datetaken"
    }
}

// extensions are often used to group protocol requirements.
//extension Photo:Equatable{
//    static func == (lhs: Photo, rhs:Photo) -> Bool {
//        return lhs.photoID == rhs.photoID
//    }
//}
