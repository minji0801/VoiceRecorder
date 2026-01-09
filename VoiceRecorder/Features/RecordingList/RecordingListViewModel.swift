//
//  RecordingListViewModel.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  목록 데이터 관리

import Foundation
import Combine

final class RecordingListViewModel {
  
  // MARK: - Published Properties
  
  @Published private(set) var recordings: [Recording] = []
  @Published private(set) var isEmpty: Bool = true
  
  // MARK: - Properties
  
  private let storageService: RecordingStorageService
  
  // MARK: - Initialization
  
  init(storageService: RecordingStorageService = .shared) {
    self.storageService = storageService
  }
  
  // MARK: - Public Methods
  
  func loadRecordings() {
    recordings = storageService.fetchAllRecordings()
    isEmpty = recordings.isEmpty
  }
  
  func deleteRecording(at index: Int) throws {
    guard index >= 0 && index < recordings.count else { return }
    let recording = recordings[index]
    try storageService.deleteRecording(recording)
    loadRecordings()
  }
  
  func deleteRecording(_ recording: Recording) throws {
    try storageService.deleteRecording(recording)
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
