//
//  FilmDetailsViewController.swift
//  TestTaskIMDB
//
//  Created by Sergey Krasnogorov on 11/7/19.
//  Copyright © 2019 Sergey Krasnogorov. All rights reserved.
//

import UIKit
import CoreData

class FilmDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage : UIImageView!
    @IBOutlet weak var descriptionText : UITextView!
    @IBOutlet weak var favouriteButton : UIButton!

    private var _record : FilmRecord? = nil
    var managedContext : NSManagedObjectContext? {
        didSet {
            print ("did set ")
        }
    }
    var detailItem: FilmRecord? {
        didSet {
            _record = detailItem!
            // Update the view.
            configureView()
        }
    }
    
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
                button.setTitle(NSLocalizedString(detail.filmIsFavourite ? "Remove from favourite" : "Add to favourite", comment: ""), for: .normal)
            }
            if let image = posterImage {
                image.downloaded(from: "https://image.tmdb.org/t/p/w500"+detail.filmPoster!)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    @IBAction func favouriteButtonClicked(_ sender: Any) {
        let value : Bool = !_record!.filmIsFavourite;
        _record?.setValue(value, forKey: "filmIsFavourite")
        do {
            try self.managedContext?.save()
            favouriteButton.setTitle(NSLocalizedString(value ? "Remove from favourite" : "Add to favourite", comment: ""), for: .normal)
        }
        catch {
            print (error)
        }
    }
}

