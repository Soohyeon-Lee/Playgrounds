//
//  NetworkImageManager.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import Foundation

final class NetworkImageManager: DataLoadable {
  static let shared = NetworkImageManager()
  private init() {}

  func loadData(key: String) async throws -> Data {
    let url = URL(string: "https://picsum.photos/\(key)")!

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse else { fatalError("Failed type casting") }

    guard (200..<300) ~= httpResponse.statusCode else { fatalError("HTTP Error") }

    return data
  }
}
