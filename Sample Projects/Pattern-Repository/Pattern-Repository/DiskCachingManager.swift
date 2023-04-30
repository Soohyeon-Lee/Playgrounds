//
//  DiskCachingManager.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import Foundation

final class DiskCacheManager: CacheManagable {
  private let fileManager = FileManager.default
  private let cachesURL: URL

  static let shared = DiskCacheManager()
  private init() {
    cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }

  func loadCachedData(key: String) -> Data? {
    let filePath = cachesURL.appending(path: key).appendingPathExtension("txt")

    return try? Data(contentsOf: filePath)
  }

  func addDataToCache(key: String, data: Data) {
    let filePath = cachesURL.appending(path: key).appendingPathExtension("txt")

    fileManager.createFile(atPath: filePath.path(), contents: data)
  }

  func removeAllCache() {
    guard let subpaths = try? fileManager.contentsOfDirectory(
      atPath: cachesURL.absoluteString
    ) else { return }

    for itemPath in subpaths {
      try? fileManager.removeItem(atPath: itemPath)
    }
  }
}
