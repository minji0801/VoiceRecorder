//
//  PlayerVM.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//

import Foundation
import Combine

final class PlayerVM {
  
  // MARK: - Properties
  
  @Published private(set) var isPlaying: Bool = false
  @Published private(set) var currentTime: TimeInterval = 0
  @Published private(set) var waveformSamples: [Float] = []
  
  let recording: Recording
  private let playerService: AudioPlayerService
  private var cancellables = Set<AnyCancellable>()
  
  var duration: TimeInterval {
    playerService.duration
  }
  
  var progress: Float {
    guard duration > 0 else { return 0 }
    return Float(currentTime / duration)
  }
  
  var formattedCurrentTime: String {
    currentTime.formatTime
  }
  
  var formattedDuration: String {
    duration.formatTime
  }
  
  var recordingName: String {
    recording.name
  }
  
  var recordingDetails: String {
    "\(recording.formattedDate) · \(recording.fileSize)"
  }
  
  // MARK: - Init
  
  init(recording: Recording, playerService: AudioPlayerService = .shared) {
    self.recording = recording
    self.playerService = playerService
    setupBindings()
  }
  
  // MARK: - Public Methods
  
  func loadAudio() throws {
    try playerService.loadAudio(url: recording.url)
  }
  
  func setWaveformSamples(_ samples: [Float]) {
    waveformSamples = samples
  }
  
  func play() {
    playerService.play()
  }
  
  func pause() {
    playerService.pause()
  }
  
  func togglePlayPause() {
    if isPlaying {
      pause()
    } else {
      play()
    }
  }
  
  func seek(to progress: Float) {
    let time = Double(progress) * duration
    playerService.seek(to: time)
  }
  
  func skip(seconds: TimeInterval) {
    playerService.skip(seconds: seconds)
  }
  
  func stop() {
    playerService.stop()
  }
  
  // MARK: - Private Methods
  
  private func setupBindings() {
    playerService.$isPlaying
      .receive(on: DispatchQueue.main)
      .assign(to: &$isPlaying)
    
    playerService.$currentTime
      .receive(on: DispatchQueue.main)
      .assign(to: &$currentTime)
    
    playerService.didFinishPlaying
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.currentTime = 0
      }
      .store(in: &cancellables)
  }
}
