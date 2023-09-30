//
//  MovieListTableViewCell.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/26/23.
//

import UIKit
import SnapKit
import Kingfisher

final class MovieListTableViewCell: UITableViewCell, ReusableCell {
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [poster, labelsStackView])
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 20
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 8)
        return view
    }()
    
    private lazy var poster: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .systemGroupedBackground
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        view.snp.makeConstraints { make in
            make.width.equalTo(Constants.posterSize.width)
            make.height.equalTo(Constants.posterSize.height)
        }
        return view
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, releaseDateLabel, voteAverageLabel])
        view.axis = .vertical
        view.spacing = 4.0
        view.setCustomSpacing(16, after: releaseDateLabel)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkText
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var voteAverageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemIndigo
        label.font = UIFont.systemFont(ofSize: 27, weight: .thin)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        selectionStyle = .none
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
        
    func config(with item: MovieListCellItem) {
        poster.kf.setImage(with: item.posterURL)
        titleLabel.text = item.title
        releaseDateLabel.text = item.releaseDate
        voteAverageLabel.text = item.voteAverage
    }
}
