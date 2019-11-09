//
//  DetailViewController.swift
//  TestTaskIMDB
//
//  Created by Sergey Krasnogorov on 11/7/19.
//  Copyright © 2019 Sergey Krasnogorov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage : UIImageView!
    @IBOutlet weak var descriptionText : UITextView!
    @IBOutlet weak var favouriteButton : UIButton!

    private var _record : FilmRecord? = nil
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = titleLabel {
                label.text = detail.filmName
            }
            if let description = descriptionText {
                description.text = detail.filmDescription
            }
            if let button = favouriteButton {
                button.titleLabel?.text = NSLocalizedString(detail.filmIsFavourite ? "Remove from favourite" : "Add to favourite", comment: "")
            }
            if let image = posterImage {
                image.downloaded(from: "https://image.tmdb.org/t/p/w500"+detail.filmPoster!)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: FilmRecord? {
        didSet {
            _record = detailItem!
            // Update the view.
            configureView()
        }
    }
    
    @IBAction func favouriteButtonClicked(_ sender: Any) {
        _record!.filmIsFavourite != _record!.filmIsFavourite;
        favouriteButton.titleLabel?.text = NSLocalizedString(_record!.filmIsFavourite ? "Remove from favourite" : "Add to favourite", comment: "")
    }
}

