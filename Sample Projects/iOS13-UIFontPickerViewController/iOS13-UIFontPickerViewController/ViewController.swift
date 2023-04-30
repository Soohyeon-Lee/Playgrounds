//
//  ViewController.swift
//  iOS13-UIFontPickerViewController
//
//  Created by Soohyeon Lee on 2023/04/07.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

  private lazy var fontPicker = buildFontPicker()
  private lazy var changeFontButton = buildChangeFontButton()
  private lazy var fontTitleLabel = buildFontTitleLabel()

  private var currentFont: UIFont? {
    didSet {
      guard let currentFont else { return }
      fontTitleLabel.font = currentFont
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    setupLayout()
  }

  @objc private func changeFontButtonTouched() {
    present(fontPicker, animated: true)
  }
}

// MARK: - Layout

extension ViewController: UIFontPickerViewControllerDelegate {
  func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
    defer { viewController.dismiss(animated: true) }

    guard let descriptor = viewController.selectedFontDescriptor else { return }
    currentFont = UIFont(descriptor: descriptor, size: currentFont?.pointSize ?? 40)
  }

  func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
    viewController.dismiss(animated: true)
  }
}

// MARK: - Layout

extension ViewController {
  private func setupLayout() {
    view.addSubview(fontTitleLabel)
    fontTitleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    view.addSubview(changeFontButton)
    changeFontButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(100)
      make.size.equalTo(CGSize(width: 120, height: 60))
    }
  }

  private func buildFontPicker() -> UIFontPickerViewController {
    let pickerVC = UIFontPickerViewController()
    pickerVC.delegate = self
    return pickerVC
  }

  private func buildChangeFontButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = .black
    button.setTitle("Change Font", for: .normal)
    button.addTarget(self, action: #selector(changeFontButtonTouched), for: .touchUpInside)
    return button
  }

  private func buildFontTitleLabel() -> UILabel {
    let label = UILabel()
    label.font = .systemFont(ofSize: 40)
    label.text = "1234567"
    return label
  }
}
