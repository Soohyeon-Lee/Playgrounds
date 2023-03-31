//
//  ViewModel.swift
//  iOS13-DiffableDataSource
//
//  Created by Soohyeon Lee on 2023/03/31.
//

import Foundation
import Combine

class ViewModel {
  let reloadPublisher = PassthroughSubject<Void, Never>()

  private(set) var dataArray = [0, 1, 2, 3, 4]
}

// MARK: - Data Manipulation

extension ViewModel {
  func append() {
    dataArray.append(dataArray.count)

    reloadPublisher.send()
  }

  func removeLast() {
    guard !dataArray.isEmpty else { return }

    dataArray.removeLast()

    reloadPublisher.send()
  }
}

// MARK: - DataSource

enum Section: CaseIterable {
  case main
}
