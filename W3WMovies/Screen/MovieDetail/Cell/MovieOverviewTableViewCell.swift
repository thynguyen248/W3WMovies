//
//  MovieOverviewTableViewCell.swift
//  W3WMovies
//
//  Created by Thy Nguyen on 9/30/23.
//

import UIKit

final class MovieOverviewTableViewCell: UITableViewCell, ReusableCell {
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, overviewLabel])
        view.axis = .vertical
        view.spacing = 4.0
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 0, right: 8)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkText
        label.font = UIFont.systemFont(ofSize: 30, weight: .thin)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 0
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
        
    func config(with item: MovieOverviewCellItem) {
        titleLabel.text = item.title
        overviewLabel.text = item.overview
    }
}
