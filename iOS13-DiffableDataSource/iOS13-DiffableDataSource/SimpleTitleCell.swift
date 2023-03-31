//
//  SimpleTitleCell.swift
//  iOS13-DiffableDataSource
//
//  Created by Soohyeon Lee on 2023/04/01.
//

import UIKit
import SnapKit

class SimpleTitleCell: UICollectionViewCell {
  static let identifier = String(describing: SimpleTitleCell.self)

  private lazy var titleLabel = buildTitleLabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
    setupStyle()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    titleLabel.text = nil
  }

  func populate(text: String) {
    titleLabel.text = text
  }
}

// MARK: - Layout

extension SimpleTitleCell {
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private func setupStyle() {
    contentView.layer.borderColor = UIColor.black.cgColor
    contentView.layer.borderWidth = 1
  }

  private func buildTitleLabel() -> UILabel {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }
}
