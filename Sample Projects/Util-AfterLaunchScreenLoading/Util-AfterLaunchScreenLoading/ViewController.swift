//
//  ViewController.swift
//  Util-AfterLaunchScreenLoading
//
//  Created by Soohyeon Lee on 2023/09/10.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

  private lazy var loadingCoverView = LoadingCoverView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .yellow
    view.addSubview(loadingCoverView)
    loadingCoverView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      guard let self else { return }

      self.loadingCoverView.playLoadingAnimation()
    }

    // when loading task is completed, call this code
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
      guard let self else { return }

      self.loadingCoverView.stopLoadingAnimation()
    }
  }
}

final class LoadingCoverView: UIView, CAAnimationDelegate {
  private var appIcon: UIImage? {
    guard
      let url = Bundle.main.url(forResource: "apple", withExtension: "png"),
      let data = try? Data(contentsOf: url),
      let image = UIImage(data: data)
    else { return nil }

    return image
  }

  private var isComplete = false

  private lazy var appIconImageView = buildAppIconImageView()

  init() {
    super.init(frame: .zero)

    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func playLoadingAnimation() {
    playAnimationOnce()
  }

  func stopLoadingAnimation() {
    isComplete = true
  }

  private func playAnimationOnce() {
    let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotation.toValue = Double.pi * 2
    rotation.duration = 1
    rotation.repeatCount = 1.0
    rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    rotation.delegate = self
    rotation.isRemovedOnCompletion = true
    appIconImageView.layer.add(rotation, forKey: "rotationAnimation")
  }

  private func setupLayout() {
    backgroundColor = .white
    addSubview(appIconImageView)
    appIconImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalTo(150)
    }
  }

  private func buildAppIconImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = appIcon
    return imageView
  }

  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if isComplete {
      UIView.animate(withDuration: 0.5) {
        self.alpha = 0
      } completion: { _ in
        self.removeFromSuperview()
      }
    } else {
      playAnimationOnce()
    }
  }
}
