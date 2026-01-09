//
//  TimeInterval+Extension.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//  시간 포맷 (formatTime → "00:00")

import Foundation

extension TimeInterval {
  /// hh:mm
  var formatTime: String {
    let minutes = Int(self) / 60
    let seconds = Int(self) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
