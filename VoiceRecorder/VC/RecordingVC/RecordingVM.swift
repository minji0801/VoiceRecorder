//
//  RecordingVM.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import Foundation
import Combine

enum RecordingState {
  case idle
  case recording
  case paused
}

final class RecordingViewModel {
  
  // MARK: - Properties
  
  @Published private(set) var state: RecordingState = .idle
  @Published private(set) var elapsedTime: TimeInterval = 0
  @Published private(set) var audioLevel: Float = 0
  
  private let recorderService: AudioRecorderService
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Initialization
  
  init(recorderService: AudioRecorderService = .shared) {
    self.recorderService = recorderService
    setupBindings()
  }
  
  // MARK: - Private Methods
  
  private func setupBindings() {
    recorderService.$elapsedTime
      .receive(on: DispatchQueue.main)
      .assign(to: &$elapsedTime)
    
    recorderService.$audioLevel
      .receive(on: DispatchQueue.main)
      .assign(to: &$audioLevel)
  }
  
  // MARK: - Public Methods
  
  func requestPermission(completion: @escaping (Bool) -> Void) {
    recorderService.requestPermission(completion: completion)
  }
  
  func startRecording() throws {
    try recorderService.startRecording()
    state = .recording
  }
  
  func stopRecording() {
    recorderService.stopRecording()
    state = .idle
  }
  
  func togglePause() {
    switch state {
      case .recording:
        recorderService.pauseRecording()
        state = .paused
      case .paused:
        recorderService.resumeRecording()
        state = .recording
      case .idle:
        break
    }
  }
}
