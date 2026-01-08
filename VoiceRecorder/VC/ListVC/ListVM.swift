//
//  ListVM.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import Foundation
import Combine

final class ListVM {
  
  // MARK: - Published Properties
  
  @Published private(set) var recordings: [Recording] = []
  @Published private(set) var isEmpty: Bool = true
  
  // MARK: - Properties
  
  private let storageManager: RecordingStorageManager
  
  // MARK: - Initialization
  
  init(storageService: RecordingStorageManager = .shared) {
    self.storageManager = storageService
  }
  
  // MARK: - Public Methods
  
  func loadRecordings() {
    recordings = storageManager.fetchAllRecordings()
    isEmpty = recordings.isEmpty
  }
  
  func deleteRecording(at index: Int) throws {
    guard index >= 0 && index < recordings.count else { return }
    let recording = recordings[index]
    try storageManager.deleteRecording(recording)
    loadRecordings()
  }
  
  func deleteRecording(_ recording: Recording) throws {
    try storageManager.deleteRecording(recording)
    loadRecordings()
  }
  
  func recording(at index: Int) -> Recording? {
    guard index >= 0 && index < recordings.count else { return nil }
    return recordings[index]
  }
  
  var numberOfRecordings: Int {
    recordings.count
  }
}
