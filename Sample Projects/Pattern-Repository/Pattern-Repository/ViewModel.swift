//
//  ViewModel.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import Foundation
import Combine

final class ViewModel {
  let dataPublisher = PassthroughSubject<Data, Never>()
  let errorPublisher = PassthroughSubject<Error, Never>()

  private let repository: ImageLoadRepository

  init(repository: ImageLoadRepository) {
    self.repository = repository
  }

  func loadImage(key: String) {
    Task {
      do {
        let imageData = try await repository.loadImage(key: key)
        dataPublisher.send(imageData)
      } catch {
        errorPublisher.send(error)
      }
    }
  }
}
