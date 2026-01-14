//
//  AudioQuality.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/14/26.
//

import Foundation
import AVFoundation

enum AudioQuality: CaseIterable {
  case low      // 낮음 (파일 작음)
  case medium   // 중간
  case high     // 높음 (고음질)
  
  var settings: [String: Any] {
    switch self {
      case .low:
        return [
          AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
          AVSampleRateKey: 22050,
          AVNumberOfChannelsKey: 1,
          AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
          AVEncoderBitRateKey: 64000
        ]
      case .medium:
        return [
          AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
          AVSampleRateKey: 44100,
          AVNumberOfChannelsKey: 1,
          AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
          AVEncoderBitRateKey: 128000
        ]
      case .high:
        return [
          AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
          AVSampleRateKey: 48000,
          AVNumberOfChannelsKey: 2,
          AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
          AVEncoderBitRateKey: 256000
        ]
    }
  }
  
  var displayName: String {
    switch self {
      case .low: return "저음질"
      case .medium: return "중음질"
      case .high: return "고음질"
    }
  }
}
