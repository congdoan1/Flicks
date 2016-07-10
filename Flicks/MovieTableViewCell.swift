//
//  MovieTableViewCell.swift
//  Flicks
//
//  Created by Doan Cong Toan on 7/9/16.
//  Copyright © 2016 Toan Doan. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie! {
        didSet {
            if let title = movie.title {
                titleLabel.text = title
            }
            
            if let overview = movie.overview {
                overviewLabel.text = overview
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGrayColor()
        selectedBackgroundView = backgroundView
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        titleLabel.highlightedTextColor = UIColor.whiteColor()
        overviewLabel.highlightedTextColor = UIColor.whiteColor()
    }
    
    override func prepareForReuse() {
        self.posterImageView.image = nil
        self.titleLabel.text = nil
        self.overviewLabel.text = nil
    }
}
