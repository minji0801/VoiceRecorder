//
//  RecordingListViewController.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  녹음 목록 화면 UI

import UIKit
import Combine
import SnapKit

final class RecordingListViewController: UIViewController {
  
  // MARK: - Properties
  
  private let timelineGraphView = TimelineGraphView()
  
  private let emptyStateLabel: UILabel = {
    let label = UILabel()
    label.text = "녹음된 파일이 없습니다"
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = .white
    label.isHidden = true
    return label
  }()
  
  private let viewModel = RecordingListViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.loadRecordings()
  }
  
  private func setupUI() {
    view.backgroundColor = .customBlack
    
    view.addSubview(timelineGraphView)
    view.addSubview(emptyStateLabel)
    timelineGraphView.delegate = self
  }
  
  private func setupConstraints() {
    timelineGraphView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
    
    emptyStateLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupBindings() {
    viewModel.$recordings
      .receive(on: DispatchQueue.main)
      .sink { [weak self] recordings in
        self?.timelineGraphView.setRecordings(recordings)
      }
      .store(in: &cancellables)
    
    viewModel.$isEmpty
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isEmpty in
        self?.updateEmptyState(isEmpty: isEmpty)
      }
      .store(in: &cancellables)
  }
  
  private func updateEmptyState(isEmpty: Bool) {
    emptyStateLabel.isHidden = !isEmpty
    timelineGraphView.isHidden = isEmpty
  }
}


// MARK: - TimelineGraphViewDelegate

extension RecordingListViewController: TimelineGraphViewDelegate {
  
  func timelineGraphView(_ view: TimelineGraphView, didSelectRecordingAt index: Int) {
    guard let recording = view.getRecording(at: index) else { return }
    let playerVC = PlayerViewController(recording: recording)
    if let sheet = playerVC.sheetPresentationController {
      sheet.detents = [.custom { _ in 400 }]
      sheet.prefersGrabberVisible = true
    }
    present(playerVC, animated: true)
  }
}
