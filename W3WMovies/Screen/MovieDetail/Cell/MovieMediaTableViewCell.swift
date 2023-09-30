//
//  MovieMediaTableViewCell.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import UIKit
import Kingfisher

final class MovieMediaTableViewCell: UITableViewCell, ReusableCell {
    private lazy var cover: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .systemGroupedBackground
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.snp.makeConstraints { make in
            make.height.equalTo(Constants.coverImageSize.height).priority(.high)
        }
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
        let view = UIStackView(arrangedSubviews: [voteAverageLabel, releaseDateLabel])
        view.axis = .vertical
        view.spacing = 4.0
        view.setCustomSpacing(16, after: releaseDateLabel)
        return view
    }()
    
    private lazy var voteAverageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkText
        label.font = UIFont.systemFont(ofSize: 27, weight: .bold)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 13, weight: .thin)
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
        addSubview(cover)
        addSubview(poster)
        addSubview(labelsStackView)
        cover.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        poster.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(cover.snp.bottom).inset(Constants.posterSize.height / 3)
            make.bottom.equalToSuperview()
        }
        labelsStackView.snp.makeConstraints { make in
            make.leading.equalTo(poster.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(poster.snp.bottom).inset(16)
        }
    }
        
    func config(with item: MovieMediaCellItem) {
        poster.kf.setImage(with: item.posterURL)
        cover.kf.setImage(with: item.coverURL)
        voteAverageLabel.text = item.voteAverage
        releaseDateLabel.text = item.releaseDate
    }
}
