//
//  ViewController.swift
//  iOS13-DiffableDataSource
//
//  Created by Soohyeon Lee on 2023/03/31.
//

import UIKit
import Combine
import SnapKit

class ViewController: UIViewController {
  typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Int>
  typealias DiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Int>

  private let viewModel = ViewModel()

  private lazy var dataSource = makeDiffableDataSource()

  private lazy var collectionView = buildCollectionView()
  private lazy var appendButton = buildAppendButton()
  private lazy var removeLastButton = buildRemoveLastButton()

  private var cancelBag = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    setupLayout()
    applyDataSource()

    viewModel.reloadPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        self.applyDataSource()
      }
      .store(in: &cancelBag)
  }

  private func makeDiffableDataSource() -> DiffableDataSource {
    DiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
      guard
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleTitleCell.identifier, for: indexPath) as? SimpleTitleCell
      else { return UICollectionViewCell() }
      cell.populate(text: "\(itemIdentifier)")
      return cell
    }
  }

  func applyDataSource() {
    var snapshot = DiffableDataSourceSnapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(viewModel.dataArray)
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  @objc private func appendButtonTouched() {
    viewModel.append()
  }

  @objc private func removeLastButtonTouched() {
    viewModel.removeLast()
  }
}

// MARK: - Layout

extension ViewController {
  private func setupLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
    }
    view.addSubview(appendButton)
    appendButton.snp.makeConstraints { make in
      make.top.equalTo(collectionView.snp.bottom)
      make.left.equalToSuperview()
      make.right.equalTo(view.snp.centerX)
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    view.addSubview(removeLastButton)
    removeLastButton.snp.makeConstraints { make in
      make.top.equalTo(collectionView.snp.bottom)
      make.left.equalTo(view.snp.centerX)
      make.right.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }

  private func buildCollectionView() -> UICollectionView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: buildCollectionViewLayout())
    collectionView.register(SimpleTitleCell.self, forCellWithReuseIdentifier: SimpleTitleCell.identifier)
    return collectionView
  }

  private func buildCollectionViewLayout() -> UICollectionViewLayout {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    return flowLayout
  }

  private func buildAppendButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = .black
    button.setTitle("Append", for: .normal)
    button.addTarget(self, action: #selector(appendButtonTouched), for: .touchUpInside)
    return button
  }

  private func buildRemoveLastButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = .black
    button.setTitle("RemoveLast", for: .normal)
    button.addTarget(self, action: #selector(removeLastButtonTouched), for: .touchUpInside)
    return button
  }
}
