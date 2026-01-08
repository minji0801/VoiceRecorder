//
//  ListVC.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import UIKit
import Combine
import SnapKit

final class ListVC: UIViewController {
  
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
  
  private let viewModel = ListVM()
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

extension ListVC: TimelineGraphViewDelegate {
  
  func timelineGraphView(_ view: TimelineGraphView, didSelectRecordingAt index: Int) {
    guard let recording = view.getRecording(at: index) else { return }
    // TODO: 재생하기
  }
}
