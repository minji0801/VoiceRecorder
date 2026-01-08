//
//  AudioRecordManager.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import UIKit
import AVFoundation
import Combine

final class AudioRecorderService: NSObject {
  
  static let shared = AudioRecorderService()
  
  private var audioRecorder: AVAudioRecorder?
  private var meteringTimer: Timer?
  private var recordingStartTime: Date?
  private var pausedDuration: TimeInterval = 0
  private var pauseStartTime: Date?
  
  @Published private(set) var isRecording: Bool = false
  @Published private(set) var audioLevel: Float = 0
  @Published private(set) var elapsedTime: TimeInterval = 0
  
  // 권한 요청
  func requestPermission(completion: @escaping (Bool) -> Void) {
    AVAudioApplication.requestRecordPermission { grated in
      completion(grated)
    }
  }
  
  // 녹음 시작
  func startRecording() throws {
    guard !isRecording else { return }
    
    let session = AVAudioSession.sharedInstance()
    
    do {
      try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
      try session.setActive(true)
      
      // TODO: 음성 품질 컨트롤하기
      let url = getFileURL()
      let settings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        AVEncoderBitRateKey: 128000
      ]
      
      audioRecorder = try AVAudioRecorder(url: url, settings: settings)
      audioRecorder?.delegate = self
      audioRecorder?.isMeteringEnabled = true
      audioRecorder?.prepareToRecord()
      
      if audioRecorder?.record() == true {
        isRecording = true
        recordingStartTime = Date()
        pausedDuration = 0
        startMeteringTimer()
      }
    } catch {
      // TODO: 오류 처리
    }
  }
  
  // 녹음 정지
  func stopRecording() {
    guard isRecording || audioRecorder?.isRecording == false else { return }
    
    stopMeteringTimer()
    audioRecorder?.stop()
    isRecording = false
    elapsedTime = 0
    audioLevel = 0
  }
  
  // 녹음 일시정지
  func pauseRecording() {
    guard audioRecorder?.isRecording == true else { return }
    audioRecorder?.pause()
    pauseStartTime = Date()
    stopMeteringTimer()
  }
  
  // 녹음 재개
  func resumeRecording() {
    if let pauseStart = pauseStartTime {
      pausedDuration += Date().timeIntervalSince(pauseStart)
      pauseStartTime = nil
    }
    audioRecorder?.record()
    startMeteringTimer()
  }
  
  // MARK: - Private Method
  
  private func startMeteringTimer() {
    meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
      self?.updateMeters()
    }
  }
  
  private func stopMeteringTimer() {
    meteringTimer?.invalidate()
    meteringTimer = nil
  }
  
  private func updateMeters() {
    guard let recorder = audioRecorder, recorder.isRecording else { return }
    
    recorder.updateMeters()
    let averagePower = recorder.averagePower(forChannel: 0)
    
    let normalizedLevel = max(0, min(1, (averagePower + 50) / 50))
    if UIApplication.shared.applicationState == .active {
      audioLevel = normalizedLevel
    }
    
    if let startTime = recordingStartTime {
      elapsedTime = Date().timeIntervalSince(startTime) - pausedDuration
    }
  }
  
  // 녹음 파일 경로
  private func getFileURL() -> URL {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let fileName = "Recording_\(dateFormatter.string(from: Date())).m4a"
    return path.appendingPathComponent(fileName)
  }
}
// MARK: - AVAudioRecorderDelegate

extension AudioRecorderService: AVAudioRecorderDelegate {
  
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    isRecording = false
  }
  
  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    isRecording = false
  }
}
