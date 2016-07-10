//
//  Movie.swift
//  Flicks
//
//  Created by Doan Cong Toan on 7/7/16.
//  Copyright © 2016 Toan Doan. All rights reserved.
//

import Foundation

class Movie {
    let title: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    
    init(dictionary: NSDictionary) {
        title = dictionary["title"] as? String
        
        if let overview = dictionary["overview"] as? String {
            self.overview = overview
        } else {
            self.overview = nil
        }
        
        if let posterPath = dictionary["poster_path"] as? String {
            self.posterPath = posterPath
        } else {
            self.posterPath = nil
        }
        
        if let releaseDate = dictionary["release_date"] as? String {
            self.releaseDate = releaseDate
        } else {
            self.releaseDate = nil
        }
        
        if let voteAverage = dictionary["vote_average"] as? Double {
            self.voteAverage = voteAverage
        } else {
            self.voteAverage = nil
        }
    }
    
    class func moviesFromDictionary(array: [NSDictionary]) -> [Movie] {
        return array.map {
            Movie(dictionary: $0)
        }
    }
    
    class func fetchMoviesWithEndPoint(endPoint: String, successCallback: ([Movie]) -> Void, errorCallback: ((NSError?) -> Void)?) {
        let url = NSURL(string: Utils.sharedInstance.getRequestURLForEndPoint(endPoint))
        
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(
            request,
            completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                if let requestError = errorOrNil {
                    errorCallback?(requestError)
                } else {
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            if let movies = responseDictionary["results"] as? [NSDictionary] {
                                successCallback(Movie.moviesFromDictionary(movies))
                            }
                        }
                    }
                }
        })
        task.resume()
    }
}
