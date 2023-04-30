//
//  SceneDelegate.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    // Test를 위해 Mock 객체로 교체 가능
    let repository = ImageLoadRepository(
      memoryCachingManager: MemoryCacheManager.shared,
      fileCachingManager: DiskCacheManager.shared,
      networkImageManager: NetworkImageManager.shared
    )
    let viewModel = ViewModel(repository: repository)
    let viewController = ViewController(viewModel: viewModel)

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
  }
}
