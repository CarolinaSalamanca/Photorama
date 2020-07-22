//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/15/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import Foundation

struct FlickrAPI{
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"

    // This is a computed property
    private static func flickrURL(endPoint: EndPoint, parameters: [String: String]?) -> URL{
        var components = URLComponents(string: baseURLString)! // declare it as optional, to use force unwrapping
        var queryItems = [URLQueryItem]() // array initialized
        
        // its a dictionary of strings
        let baseParams: [String: String] = ["method":  endPoint.rawValue, "format": "json", "nojsoncallback": "1", "api_key": apiKey]
        for (key, value) in baseParams{
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters{
            for (key, value) in additionalParams{
                let queryItem = URLQueryItem(name: key, value: value)
                queryItems.append(queryItem)
            }
        }
        
        components.queryItems = queryItems
        return components.url!
    }
    
    // a type method
    static var interestingPhotosURL: URL {
        return flickrURL(endPoint: .interestingPhotos, parameters: ["extras": "url_z,date_taken"])
    }
    
    // Result is an enum and a generic type it can receive anything in succes but its mandatory to send an error (llok at the definition)
    static func photos(fromJSON data: Data) -> Result<[FlickrPhoto], Error> {
        do {
            let decoder = JSONDecoder()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            
            let flickrResponse = try decoder.decode(FlickrResponse.self, from: data)
          
            // returns an enum with an associated value (enums may have an associated value and a raw value(they are different))
            let photos = flickrResponse.photosInfo.photos.filter { $0.remoteURL != nil } // gets the ones that have a picture
            return .success(photos)
        } catch {
            return .failure(error)
        }
    }
}

enum EndPoint: String {
    case interestingPhotos = "flickr.interestingness.getList" // it has a raw value
}

struct FlickrResponse: Codable {
    let photosInfo: FlickrPhotosResponse

    enum CodingKeys: String, CodingKey {
        case photosInfo = "photos"
    }
}
struct FlickrPhotosResponse: Codable {
    let photos: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}
