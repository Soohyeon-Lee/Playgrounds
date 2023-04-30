//
//  ImageLoadRepository.swift
//  Pattern-Repository
//
//  Created by Soohyeon Lee on 2023/04/30.
//

import Foundation

protocol DataLoadable {
  func loadData(key: String) async throws -> Data
}

protocol CacheManagable {
  func loadCachedData(key: String) -> Data?
  func addDataToCache(key: String, data: Data)
  func removeAllCache()
}

final class ImageLoadRepository {
  private let memoryCachingManager: CacheManagable
  private let diskCachingManager: CacheManagable
  private let networkImageManager: DataLoadable

  init(
    memoryCachingManager: CacheManagable,
    fileCachingManager: CacheManagable,
    networkImageManager: DataLoadable
  ) {
    self.memoryCachingManager = memoryCachingManager
    self.diskCachingManager = fileCachingManager
    self.networkImageManager = networkImageManager
  }

  func loadImage(key: String) async throws -> Data {
    var imageData: Data?

    // 메모리에 캐싱된 데이터가 있으면 바로 반환
    if let cachedData = memoryCachingManager.loadCachedData(key: key) {
      print(#function, "Key: \(key), Load from Memory Cache")
      return cachedData
    }

    // 메모리에 캐싱된 데이터가 없으면 함수 종료 시점에 데이터를 메모리에 캐싱
    defer {
      if let imageData {
        memoryCachingManager.addDataToCache(key: key, data: imageData)
      }
    }

    // 캐시 디렉토리에 데이터가 있으면 바로 반환
    if let cachedData = diskCachingManager.loadCachedData(key: key) {
      print(#function, "Key: \(key), Load from File Cache")
      imageData = cachedData
      return cachedData
    }

    // 캐시 디렉토리에 데이터가 없으면 함수 종료 시점에 데이터를 캐시 디렉토리에 저장
    defer {
      if let imageData {
        diskCachingManager.addDataToCache(key: key, data: imageData)
      }
    }

    // 캐시 레이어에 없으면 네트워크를 통한 로드
    let networkImageData = try await networkImageManager.loadData(key: key)
    print(#function, "Key: \(key), Load by Network")
    imageData = networkImageData
    return networkImageData
  }
}
