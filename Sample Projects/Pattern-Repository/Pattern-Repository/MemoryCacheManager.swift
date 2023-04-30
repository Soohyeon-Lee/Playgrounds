//
//  MemoryCacheManager.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import Foundation

final class MemoryCacheManager: CacheManagable {
  private let cache = NSCache<NSString, NSData>()

  static let shared = MemoryCacheManager()
  private init() {}

  func loadCachedData(key: String) -> Data? {
    cache.object(forKey: key as NSString) as Data?
  }

  func addDataToCache(key: String, data: Data) {
    cache.setObject(data as NSData, forKey: key as NSString)
  }

  func removeAllCache() {
    cache.removeAllObjects()
  }
}
