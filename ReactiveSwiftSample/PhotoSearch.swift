//
//  SearchPhotoViewModel.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import Foundation

// Provides an interface for querying the 500px search API
class PhotoSearch {
  
  let host = "https://api.500px.com/"
  let apiMethod = "v1/photos/search"
  let key: String
  
  private static var formatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter
  }()
  
  init(key: String) {
    self.key = key
  }

  // Find photos that match the supplied query, results are returned asynchronously
  // via the supplied callback
  func findPhotos(query: PhotoQuery, callback: Result<PhotoArray> -> ())  {
    
    // convert the PhotoQuery into querystring parameters
    let params = [
      "consumer_key": key,
      "image_size": "4",
      "term": query.text,
      "license_type": query.creativeCommonsLicence ? "1,2,3,4,5,6" : "0"
    ];
    
    let querystring = params.map { key, value in "\(key)=\(value)" }
      .joinWithSeparator("&");
    
    // construct the query URL
    guard let url = NSURL(string: "\(host)\(apiMethod)?\(querystring)") else {
      callback(.Error(PhotoSearchError.MalformedRequest))
      return
    }
    // perform the request
    let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
      (data, response, error) in
      
      // dispatch onto the main thread
      dispatch_async(dispatch_get_main_queue()) {
        do {
          // parse the results, then filter based on date
          let result = try self.parseSearchResults(data!)
            .filter {
              photo in
              if query.dateFilter {
                return photo.date.timeIntervalSinceDate(query.minDate) > 0 &&
                  photo.date.timeIntervalSinceDate(query.maxDate) < 0
              } else {
                return true
              }
            }
          callback(Result.Success(result))
        } catch {
          callback(Result.Error(PhotoSearchError.ParseError))
        }
      }
    }
    
    task.resume()
  }
  
  // parses the JSON data returned by the 50px API
  private func parseSearchResults(data: NSData) throws -> PhotoArray {
    
    // convert the JSON response into a dictionary
    guard
      let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary,
      let photos = jsonDict["photos"] as? [NSDictionary] else {
        throw PhotoSearchError.ParseError
    }
    
    let parsedPhotos = photos.map {
      photoDict -> Photo? in
        // parse each photo instance - if an error occurs, return nil
        guard let imageUrl = photoDict["image_url"] as? String,
          let name = photoDict["name"] as? String,
          let dateString = photoDict["created_at"] as? String,
          let date = PhotoSearch.formatter.dateFromString(dateString),
          let url = NSURL(string: imageUrl) else {
            return nil
        }
        
        return Photo(title: name, url: url, date: date)
      }
      // flatMap to unwrap optionals and remove nils
      .flatMap { return $0! }
    
    return parsedPhotos;
  }

}
