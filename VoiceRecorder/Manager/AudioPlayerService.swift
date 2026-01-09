//
//  AudioPlayerService.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//

import Foundation
import AVFoundation
import Combine

final class AudioPlayerService: NSObject {
  
  // MARK: - Properties
  
  static let shared = AudioPlayerService()
  
  @Published private(set) var isPlaying: Bool = false
  @Published private(set) var currentTime: TimeInterval = 0
  @Published private(set) var audioLevel: Float = 0
  
  private(set) var duration: TimeInterval = 0
  private(set) var currentURL: URL?
  
  let didFinishPlaying = PassthroughSubject<Void, Never>()
  
  private var audioPlayer: AVAudioPlayer?
  private var playbackTimer: Timer?
  
  // MARK: - Init
  
  private override init() {
    super.init()
  }
  
  // MARK: - Public Method
  
  // 녹음 파일 셋팅
  func loadAudio(url: URL) throws {
    stop()
    
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback, mode: .default)
    try session.setActive(true)
    
    audioPlayer = try AVAudioPlayer(contentsOf: url)
    audioPlayer?.delegate = self
    audioPlayer?.isMeteringEnabled = true
    audioPlayer?.prepareToPlay()
    
    currentURL = url
    duration = audioPlayer?.duration ?? 0
    currentTime = 0
  }
  
  // 재생
  func play() {
    guard let player = audioPlayer else { return }
    player.play()
    isPlaying = true
    startPlaybackTimer()
  }
  
  // 일시정시
  func pause() {
    audioPlayer?.pause()
    isPlaying = false
    stopPlaybackTimer()
  }
  
  // 정지
  func stop() {
    audioPlayer?.stop()
    audioPlayer?.currentTime = 0
    isPlaying = false
    currentTime = 0
    stopPlaybackTimer()
  }
  
  // 재생 위치 이동 (드래그)
  func seek(to time: TimeInterval) {
    audioPlayer?.currentTime = time
    currentTime = time
    updatePlaybackInfo()
  }
  
  // 재생 위치 이동 (앞/뒤)
  func skip(seconds: TimeInterval) {
    guard let player = audioPlayer else { return }
    let newTime = max(0, min(player.duration, player.currentTime + seconds))
    seek(to: newTime)
  }
  
  // MARK: - Private Methods
  
  private func startPlaybackTimer() {
    playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
      self?.updatePlaybackInfo()
    }
  }
  
  private func stopPlaybackTimer() {
    playbackTimer?.invalidate()
    playbackTimer = nil
  }
  
  private func updatePlaybackInfo() {
    guard let player = audioPlayer else { return }
    
    player.updateMeters()
    let averagePower = player.averagePower(forChannel: 0)
    audioLevel = max(0, min(1, (averagePower + 60) / 60))
    
    currentTime = player.currentTime
  }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayerService: AVAudioPlayerDelegate {
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    isPlaying = false
    stopPlaybackTimer()
    didFinishPlaying.send()
  }
  
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    isPlaying = false
    stopPlaybackTimer()
  }
}
