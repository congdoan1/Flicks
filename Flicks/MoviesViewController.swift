//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Doan Cong Toan on 7/7/16.
//  Copyright © 2016 Toan Doan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerToggle: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkError: UIView!
    
    var movies: [Movie]?
    var filteredMovies: [Movie]?
    var endPoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchBar.delegate = self
        
        //Add table view refresh control
        let refreshControlTV = UIRefreshControl()
        refreshControlTV.addTarget(self, action: #selector(fetchMovies(_:_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTV, atIndex: 0)
        
        //Add collection view refresh control
        let refreshControlCV = UIRefreshControl()
        refreshControlCV.addTarget(self, action: #selector(fetchMovies(_:_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControlCV, atIndex: 0)
        
        filteredMovies = movies
        fetchMovies(refreshControlTV, refreshControlCV)
    }
    
    func fetchMovies(refreshControlTV: UIRefreshControl, _ refreshControlCV: UIRefreshControl) {
        let refreshing = refreshControlTV.refreshing || refreshControlCV.refreshing
        self.hideNetworkError()
        if !refreshing {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        Movie.fetchMoviesWithEndPoint(
            endPoint,
            successCallback: { movies in
                if !refreshing {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                self.movies = movies
                self.filteredMovies = self.movies
                self.tableView.reloadData()
                self.collectionView.reloadData()
                refreshControlTV.endRefreshing()
                refreshControlCV.endRefreshing()
            },
            errorCallback: { error in
                if !refreshing {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                self.showNetworkError()
                refreshControlTV.endRefreshing()
                refreshControlCV.endRefreshing()
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapToggle(sender: AnyObject) {
        var transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromLeft, .ShowHideTransitionViews]
        var inView: UIView! = collectionView
        var outView: UIView! = tableView
        
        if containerToggle.selectedSegmentIndex == 0 {
            transitionOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
            inView = tableView
            outView = collectionView
        }
        
        UIView.transitionWithView(outView, duration: 1.0, options: transitionOptions, animations: {
            outView.hidden = true
            }, completion: nil)
        UIView.transitionWithView(inView, duration: 1.0, options: transitionOptions, animations: {
            inView.hidden = false
            }, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let movieDetailsVC = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = tableView.indexPathForSelectedRow
        movieDetailsVC.hidesBottomBarWhenPushed = true
        movieDetailsVC.movie = filteredMovies?[(indexPath?.row)!]
    }
    
    func showNetworkError() {
        self.networkError.alpha = 0.0
        self.networkError.hidden = false
        UIView.animateWithDuration(0.6, animations: {
            self.networkError.alpha = 1.0
        })
    }
    
    func hideNetworkError() {
        if self.networkError.hidden == false {
            UIView.animateWithDuration(0.6, animations: {
                self.networkError.alpha = 0.0
            })
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell") as! MovieTableViewCell
        
        cell.titleLabel.text = nil
        cell.overviewLabel.text = nil
        cell.posterImageView.image = nil
        
        cell.movie = filteredMovies?[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionViewCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        cell.posterImageView.image = nil
        cell.releaseDateLabel.text = nil
        cell.ratingLabel.text = nil
        
        cell.movie = filteredMovies?[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let movieDetailsVC = storyboard.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as! MovieDetailsViewController
        movieDetailsVC.hidesBottomBarWhenPushed = true
        movieDetailsVC.movie = filteredMovies?[indexPath.row]
        navigationController?.pushViewController(movieDetailsVC, animated: true)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies?.filter({ (movie: Movie) -> Bool in
            return (movie.title!).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        filteredMovies = movies
        tableView.reloadData()
        collectionView.reloadData()
    }
}
