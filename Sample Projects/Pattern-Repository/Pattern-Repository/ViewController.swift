//
//  ViewController.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import UIKit
import Combine
import SnapKit

class ViewController: UIViewController {
  private let viewModel: ViewModel

  private var cancelBag = Set<AnyCancellable>()

  private lazy var imageView = buildImageView()
  private lazy var textField = buildTextField()
  private lazy var loadButton = buildLoadButton()

  init(viewModel: ViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupLayout()

    viewModel.dataPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak imageView] data in
        imageView?.image = UIImage(data: data)
      }
      .store(in: &cancelBag)
  }

  @objc private func loadButtonTouched() {
    guard let key = textField.text, !key.isEmpty else { return }

    viewModel.loadImage(key: key)
  }
}

// MARK: - Layout

extension ViewController {
  private func setupLayout() {
    view.backgroundColor = .white

    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(32)
      make.height.equalTo(imageView.snp.width)
    }
    view.addSubview(textField)
    textField.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(32)
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(50)
    }
    view.addSubview(loadButton)
    loadButton.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
      make.height.equalTo(50)
    }
  }

  private func buildImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.backgroundColor = .lightGray
    imageView.contentMode = .scaleAspectFit
    return imageView
  }

  private func buildTextField() -> UITextField {
    let textField = UITextField()
    textField.layer.borderColor = UIColor.black.cgColor
    textField.layer.borderWidth = 1
    return textField
  }

  private func buildLoadButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = .black
    button.setTitle("Load", for: .normal)
    button.addTarget(self, action: #selector(loadButtonTouched), for: .touchUpInside)
    return button
  }
}
