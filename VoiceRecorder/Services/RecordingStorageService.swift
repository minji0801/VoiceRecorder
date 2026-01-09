//
//  RecordingStorageService.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  파일 저장/조회/삭제

import Foundation
import AVFoundation

final class RecordingStorageService {
  
  static let shared = RecordingStorageService()
  
  private let fileManager = FileManager.default
  
  private var documentsDirectory: URL {
    fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  
  private init() {}
  
  // MARK: - Public Methods
  
  // 녹음 파일 가져오기
  func fetchAllRecordings() -> [Recording] {
    do {
      let files = try fileManager.contentsOfDirectory(
        at: documentsDirectory,
        includingPropertiesForKeys: [.creationDateKey],
        options: .skipsHiddenFiles
      )
      
      let recordings = files
        .filter { $0.pathExtension == "m4a" }
        .compactMap { url -> Recording? in
          return createRecording(from: url)
        }
        .sorted { $0.createdAt > $1.createdAt }
      
      return recordings
    } catch {
      return []
    }
  }
  
  // 녹음 파일 삭제하기
  func deleteRecording(_ recording: Recording) throws {
    try fileManager.removeItem(at: recording.url)
  }
  
  // MARK: - Private Methods
  
  // Recording 구조체 변환
  private func createRecording(from url: URL) -> Recording? {
    do {
      let attributes = try fileManager.attributesOfItem(atPath: url.path)
      let createdAt = attributes[.creationDate] as? Date ?? Date()
      
      let asset = AVURLAsset(url: url)
      let duration = CMTimeGetSeconds(asset.duration)
      
      let name = url.deletingPathExtension().lastPathComponent
      
      return Recording(
        id: UUID(),
        url: url,
        createdAt: createdAt,
        duration: duration.isNaN ? 0 : duration,
        name: name
      )
    } catch {
      return nil
    }
  }
}
