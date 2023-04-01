//
//  ViewController.swift
//  PhotoLibraryPermission
//
//  Created by Soohyeon Lee on 2023/04/01.
//

import UIKit
import Combine
import Photos
import SnapKit

class ViewController: UIViewController {

  private lazy var handlerButton = buildHandlerButton()
  private lazy var publisherButton = buildPublisherButton()
  private lazy var concurrencyButton = buildConcurrencyButton()

  private var cancelBag = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    setupLayout()
  }

  @objc private func handlerButtonTouched() {
    PermissionProvider.requestAuthorization { [weak self] status in
      guard self?.checkPermissionStatus(status) == true else { return }

      self?.presentImagePicker()
    }
  }

  @objc private func publisherButtonTouched() {
    PermissionProvider.requestAuthorization()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        guard self?.checkPermissionStatus(status) == true else { return }

        self?.presentImagePicker()
      }
      .store(in: &cancelBag)
  }

  @objc private func concurrencyButtonTouched() {
    guard #available(iOS 14, *) else { return }

    Task {
      let status = await PermissionProvider.requestAuthorization()

      guard checkPermissionStatus(status) else { return }
      presentImagePicker()
    }
  }

  private func checkPermissionStatus(_ status: PHAuthorizationStatus) -> Bool {
    if #available(iOS 14, *) {
      return status == .authorized || status == .limited
    } else {
      return status == .authorized
    }
  }

  private func presentImagePicker() {
    print("사진 라이브러리 권한 있음!")
  }
}

// MARK: - Layout

extension ViewController {
  private func setupLayout() {
    view.addSubview(handlerButton)
    handlerButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-80)
      make.size.equalTo(CGSize(width: 180, height: 60))
    }
    view.addSubview(publisherButton)
    publisherButton.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalTo(CGSize(width: 180, height: 60))
    }
    view.addSubview(concurrencyButton)
    concurrencyButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(80)
      make.size.equalTo(CGSize(width: 180, height: 60))
    }
  }

  private func buildHandlerButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = . black
    button.setTitle("Handler", for: .normal)
    button.addTarget(self, action: #selector(handlerButtonTouched), for: .touchUpInside)
    return button
  }

  private func buildPublisherButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = . black
    button.setTitle("Publisher", for: .normal)
    button.addTarget(self, action: #selector(publisherButtonTouched), for: .touchUpInside)
    return button
  }

  private func buildConcurrencyButton() -> UIButton {
    let button = UIButton()
    button.backgroundColor = . black
    button.setTitle("Concurrency", for: .normal)
    button.addTarget(self, action: #selector(concurrencyButtonTouched), for: .touchUpInside)
    return button
  }
}
