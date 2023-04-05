//
//  PermissionProvider.swift
//  PhotoLibraryPermission
//
//  Created by Soohyeon Lee on 2023/04/01.
//

import Foundation
import Combine
import Photos

enum PermissionProvider {
  static func requestAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        completion(status)
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        completion(status)
      }
    }
  }

  static func requestAuthorization() -> Future<PHAuthorizationStatus, Never> {
    return Future { promise in
      if #available(iOS 14, *) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
          promise(.success(status))
        }
      } else {
        PHPhotoLibrary.requestAuthorization { status in
          promise(.success(status))
        }
      }
    }
  }

  @available(iOS 14, *)
  static func requestAuthorization() async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: .readWrite)
  }
}
