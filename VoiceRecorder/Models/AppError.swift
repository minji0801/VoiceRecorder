//
//  AppError.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/14/26.
//  사용자 친화적 에러 정의

import Foundation

enum RecordingError: LocalizedError {
  case permissionDenied
  case sessionSetupFailed
  case recorderInitFailed
  case recordingFailed
  case unknown
  
  var errorDescription: String? {
    switch self {
      case .permissionDenied:
        return "마이크 접근 권한이 필요합니다.\n설정에서 마이크 권한을 허용해주세요."
      case .sessionSetupFailed:
        return "오디오 세션을 시작할 수 없습니다.\n다른 앱에서 오디오를 사용 중인지 확인해주세요."
      case .recorderInitFailed:
        return "녹음기를 초기화할 수 없습니다.\n저장 공간이 부족하거나 파일 접근에 문제가 있습니다."
      case .recordingFailed:
        return "녹음을 시작할 수 없습니다.\n잠시 후 다시 시도해주세요."
      case .unknown:
        return "알 수 없는 오류가 발생했습니다.\n앱을 재시작해주세요."
    }
  }
}

enum PlaybackError: LocalizedError {
  case fileNotFound
  case invalidFormat
  case playerInitFailed
  case unknown
  
  var errorDescription: String? {
    switch self {
      case .fileNotFound:
        return "녹음 파일을 찾을 수 없습니다.\n파일이 삭제되었을 수 있습니다."
      case .invalidFormat:
        return "지원하지 않는 오디오 형식입니다."
      case .playerInitFailed:
        return "재생기를 초기화할 수 없습니다.\n파일이 손상되었을 수 있습니다."
      case .unknown:
        return "재생 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요."
    }
  }
}
