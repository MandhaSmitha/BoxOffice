//
//  MovieListTableViewCell.swift
//  BoxOffice
//
//  Created by Smitha Mandha on 7/8/18.
//  Copyright © 2018 SmithaReddy. All rights reserved.
//

import UIKit
import SDWebImage

class MovieListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var releaseDateTitleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    var viewModel: MovieListCellViewModel? {
        didSet {
            setupView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupView() {
        nameTitleLabel.text = NSLocalizedString("MovieListCell_NameTitle_Text", comment: "movie title text")
        nameLabel.text = viewModel?.nameText
        releaseDateTitleLabel.text = NSLocalizedString("MovieListCell_ReleaseDateTitle_Text", comment: "Release date text")
        releaseDateLabel.text = viewModel?.releaseDateText
        overviewLabel.text = viewModel?.fullOverviewText
        if let posterURL = viewModel?.posterURL {
            posterImageView.sd_setImage(with: URL(string: posterURL), placeholderImage: nil, options: .progressiveDownload, completed: nil)
        }
    }
}
