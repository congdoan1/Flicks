//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Doan Cong Toan on 7/7/16.
//  Copyright © 2016 Toan Doan. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var movieInfoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var releaseDateImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadPosterImage()
        
        titleLabel.text = movie.title
        titleLabel.sizeToFit()
        
        overviewLabel.text = movie.overview
        overviewLabel.sizeToFit()
        
        if let releaseDate = movie.releaseDate {
            releaseDateLabel.text = formatDate(releaseDate, format: .Long)
        }
        
        if let voteAverage = movie.voteAverage {
            ratingLabel.text = "\(voteAverage)"
            ratingLabel.textAlignment = NSTextAlignment.Right
        }
        
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(
            0.5,
            delay: 0.0,
            options: [.CurveEaseInOut],
            animations: {
                self.movieInfoView.frame.origin.y = self.movieInfoView.frame.origin.y - 30
            },
            completion: { finished in
                UIView.animateWithDuration(
                    0.5,
                    delay: 0.0,
                    options: [.CurveEaseInOut],
                    animations: {
                        self.movieInfoView.frame.origin.y = self.movieInfoView.frame.origin.y + 30
                    },
                    completion: nil)
                
            }
        )
    }
    
    private func setupViews() {
        let padding = CGFloat(8)
        let movieInfoViewDefaultVisableHeight = CGFloat(titleLabel.bounds.height + releaseDateLabel.frame.height + padding * 3)
        
        // This is too keep the user from seeing the bottom of the movieInfoView
        // when they scroll up. By adding it to the movieInfoView, and subtracting
        // it from the content height you have more content than the scroll view
        // can scroll.
        let overflowHeight = CGFloat(1000)
        
        let movieInfoViewHeight = titleLabel.bounds.height + overviewLabel.bounds.height + releaseDateLabel.frame.height + padding * 5 + overflowHeight
        movieInfoView.frame.origin = CGPoint(x: view.bounds.origin.x, y: view.bounds.height - movieInfoViewDefaultVisableHeight)
        movieInfoView.frame.size = CGSize(width: movieInfoView.frame.width, height: movieInfoViewHeight)
        
        let releaseDateOriginY = titleLabel.bounds.height + padding * 2
        releaseDateLabel.frame.origin = CGPoint(x: releaseDateLabel.frame.origin.x, y: releaseDateOriginY)
        releaseDateImage.frame.origin = CGPoint(x: releaseDateImage.frame.origin.x, y: releaseDateOriginY)
        
        let ratingOriginY = releaseDateOriginY
        ratingLabel.frame.origin = CGPoint(x: ratingLabel.frame.origin.x, y: ratingOriginY)
        ratingImage.frame.origin = CGPoint(x: ratingImage.frame.origin.x, y: ratingOriginY)
        
        let overviewOriginY = titleLabel.bounds.height + releaseDateLabel.bounds.height + padding * 3
        overviewLabel.frame.origin = CGPoint(x: overviewLabel.frame.origin.x, y: overviewOriginY)
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height + movieInfoView.frame.height - movieInfoViewDefaultVisableHeight - overflowHeight
        scrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func loadPosterImage() {
        if let posterPath = movie.posterPath {
            let lowImageRequest = NSURLRequest(URL: NSURL(string: Utils.LowBasePosterURL + posterPath)!)
            let highImageRequest = NSURLRequest(URL: NSURL(string: Utils.HighBasePosterURL + posterPath)!)
            
            self.posterImageView.setImageWithURLRequest(
                lowImageRequest,
                placeholderImage: nil,
                success: { (lowImageRequest, lowImageResponse, lowImage) -> Void in
                    
                    // lowImageResponse will be nil if the image is cached
                    if lowImageResponse != nil {
                        print("lowImage was NOT cached, fade in image")
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = lowImage
                        UIView.animateWithDuration(
                            0.3,
                            animations: { () -> Void in
                                self.posterImageView.alpha = 1.0
                            },
                            completion: { (success) -> Void in
                                self.posterImageView.setImageWithURLRequest(
                                    highImageRequest,
                                    placeholderImage: lowImage,
                                    success: { (highImageRequest, highImageResponse, highImage) -> Void in
                                        self.posterImageView.image = highImage
                                    },
                                    failure: { (highImageRequest, highImageResponse, highImage) in
                                        // do something for the failure condition
                                    }
                                )
                            }
                        )
                    } else {
                        print("lowImage was cached so just update the image")
                        self.posterImageView.setImageWithURLRequest(
                            highImageRequest,
                            placeholderImage: lowImage,
                            success: { (highImageRequest, highImageResponse, highImage) -> Void in
                                self.posterImageView.image = highImage
                            },
                            failure: { (highImageRequest, highImageResponse, highImage) in
                                // do something for the failure condition
                            }
                        )
                    }
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
            })
        }
    }
}
