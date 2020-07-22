//
//  PhotoStore.swift
//  Photorama
//
//  Created by Carolina Salamanca on 7/15/20.
//  Copyright © 2020 Carolina Salamanca. All rights reserved.
//

import UIKit
import CoreData

enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}

class PhotoStore{
    
    let imageStore = ImageStore()
    
    // next block is to work with coredata
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    // this is a closure, has () at the end and = after the type
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // MARK: Do simple request
    func fetchInterestingPhotos(completion: @escaping (Result<[Photo], Error>) -> Void){
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            var result = self.processPhotosRequest(data: data, error: error)
                  if case .success = result {
                      do {
                          try self.persistentContainer.viewContext.save()
                      } catch {
                          result = .failure(error)
                      }
                  }
            //to execute the closure on the main thread and update the UI
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume() // start the request
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> Result<[Photo], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        // return FlickerAPI.photos(fromJSON: jsonData) removed to work with core data
        
        let context = persistentContainer.viewContext

        switch FlickrAPI.photos(fromJSON: jsonData) {
            case let .success(flickrPhotos):
               let photos = flickrPhotos.map { flickrPhoto -> Photo in
                let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                let predicate = NSPredicate(
                    format: "\(#keyPath(Photo.photoID)) == \(flickrPhoto.photoID)"
                )
                fetchRequest.predicate = predicate
                var fetchedPhotos: [Photo]?
                context.performAndWait {
                    fetchedPhotos = try? fetchRequest.execute()
                }
                if let existingPhoto = fetchedPhotos?.first {
                    return existingPhoto
                }

                   var photo: Photo!
                   context.performAndWait {
                       photo = Photo(context: context)
                       photo.title = flickrPhoto.title
                       photo.photoID = flickrPhoto.photoID
                       photo.remoteURL = flickrPhoto.remoteURL
                       photo.dateTaken = flickrPhoto.dateTaken
                   }
                   return photo
               }
               return .success(photos)
            case let .failure(error):
               return .failure(error)
        }
    }
    
    //MARK: Methods to download images
    func fetchImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
//        this was removed when core data was implemented
        //let photoKey = photo.photoID
        
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        // if image is in cache return it, else fetch it
        if let image = imageStore.image(forKey: photoKey) {
           OperationQueue.main.addOperation {
               completion(.success(image))
           }
           return
        }
        
        guard let photoURL = photo.remoteURL else {
            completion(.failure(PhotoError.missingImageURL))
            return
        }
        
        let request = URLRequest(url: photoURL)

        let task = session.dataTask(with: request) {
            (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)
            
            // save image in cache
            if case let .success(image) = result {
              self.imageStore.setImage(image, forKey: photoKey)
            }
            
            // to execute the closure on the main thread and update the UI
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> Result<UIImage, Error> {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {

                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    func fetchAllPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken),
                                               ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]

        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

