//
//  Utils.swift
//  Flicks
//
//  Created by Doan Cong Toan on 7/7/16.
//  Copyright © 2016 Toan Doan. All rights reserved.
//

import Foundation

struct Constants {
    enum DateFormat {
        case Long, Short
    }
}

func formatDate(date: String, format: Constants.DateFormat) -> String? {
    var formattedDate: String?
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    if let date = dateFormatter.dateFromString(date) {
        if format == .Long {
            dateFormatter.dateStyle = .LongStyle
            dateFormatter.timeStyle = .NoStyle
            formattedDate = dateFormatter.stringFromDate(date)
        } else if format == .Short {
            dateFormatter.dateFormat = "MMM yyyy"
            formattedDate = dateFormatter.stringFromDate(date)
        }
    }
    
    return formattedDate
}

class Utils {
    static let sharedInstance = Utils()
    
    static let APIKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    static let BaseURL = "https://api.themoviedb.org/3/movie/"
    static let BasePosterURL = "https://image.tmdb.org/t/p/w342"
    static let LowBasePosterURL = "https://image.tmdb.org/t/p/w45"
    static let HighBasePosterURL = "https://image.tmdb.org/t/p/original"
    
    func getRequestURLForEndPoint(endPoint: String) -> String {
        return Utils.BaseURL + endPoint + "?api_key=\(Utils.APIKey)"
    }
}
