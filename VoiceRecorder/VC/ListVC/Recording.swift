//
//  Recording.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import Foundation

struct Recording: Identifiable, Equatable {
  let id: UUID                // 고유 식별자
  let url: URL                // 오디오 파일 경로
  let createdAt: Date         // 녹음 생성 시간
  let duration: TimeInterval  // 녹음 길이
  var name: String            // 녹음 이름
  
  /// 날짜 포맷: yyyy.MM.dd HH:mm 형식
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd HH:mm"
    return formatter.string(from: createdAt)
  }
  
  /// 파일 사이즈
  var fileSize: String {
    do {
      let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
      if let size = attributes[.size] as? Int64 {
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
      }
    } catch {
      return "Unknown"
    }
    return "Unknown"
  }
  
  static func == (lhs: Recording, rhs: Recording) -> Bool {
    return lhs.id == rhs.id
  }
}
