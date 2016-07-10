//
//  MovieCollectionViewCell.swift
//  Flicks
//
//  Created by Doan Cong Toan on 7/8/16.
//  Copyright © 2016 Toan Doan. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var movie: Movie! {
        didSet {
            if let releaseDate = movie.releaseDate {
                releaseDateLabel.text = formatDate(releaseDate, format: .Short)
            }
            
            if let rating = movie.voteAverage {
                ratingLabel.text = String(format: "%.1f", arguments: [rating])
            }
            
            if let posterPath = movie.posterPath {
                let imageRequest = NSURLRequest(URL: NSURL(string: Utils.BasePosterURL + posterPath)!)
                
                self.posterImageView.setImageWithURLRequest(
                    imageRequest,
                    placeholderImage: nil,
                    success: { (imageRequest, imageResponse, image) -> Void in
                        
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil {
                            print("Image was NOT cached, fade in image")
                            self.posterImageView.alpha = 0.0
                            self.posterImageView.image = image
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.posterImageView.alpha = 1.0
                            })
                            
                        } else {
                            print("Image was cached so just update the image")
                            self.posterImageView.image = image
                        }
                    },
                    failure: { (imageRequest, imageResponse, image) -> Void in
                        // do something for the failure condition
                })
            }
        }
    }
    
    override func prepareForReuse() {
        self.posterImageView.image = nil
        self.releaseDateLabel.text = nil
        self.ratingLabel.text = nil
    }
}
