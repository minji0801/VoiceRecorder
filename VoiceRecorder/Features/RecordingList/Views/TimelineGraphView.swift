//
//  TimelineGraphView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  타임라인 그래프 뷰

import UIKit
import SnapKit

protocol TimelineGraphViewDelegate: AnyObject {
  func timelineGraphView(_ view: TimelineGraphView, didSelectRecordingAt index: Int)
}

final class TimelineGraphView: UIView {
  
  // MARK: - Properties
  
  weak var delegate: TimelineGraphViewDelegate?
  
  private var recordings: [Recording] = []
  private let rowHeight: CGFloat = 44
  private let leftPadding: CGFloat = 70
  private let rightPadding: CGFloat = 16
  private let topPadding: CGFloat = 40
  private let hourWidth: CGFloat = 80
  
  private var startHour: Int = 0
  private var endHour: Int = 24
  private var timelineWidth: CGFloat {
    CGFloat(endHour - startHour) * hourWidth
  }
  
  // 헤더(row)
  private let headerScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isUserInteractionEnabled = false
    return scrollView
  }()
  
  private let headerContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .customNavy
    return view
  }()
  
  // 헤더(colunm)
  private let dateColumnScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.isUserInteractionEnabled = false
    return scrollView
  }()
  
  private let dateColumnContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .customNavy
    return view
  }()
  
  // 메인
  private let mainScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = true
    scrollView.showsHorizontalScrollIndicator = true
    scrollView.alwaysBounceVertical = true
    scrollView.alwaysBounceHorizontal = true
    return scrollView
  }()
  
  private let contentView = UIView()
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    setupUI()
    setupConstraints()
    setupGesture()
    mainScrollView.delegate = self
  }
  
  private func setupUI() {
    backgroundColor = .customNavy
    layer.cornerRadius = 12
    clipsToBounds = true
    
    addSubview(headerScrollView)
    headerScrollView.addSubview(headerContentView)
    
    addSubview(mainScrollView)
    mainScrollView.addSubview(contentView)
    
    addSubview(dateColumnScrollView)
    dateColumnScrollView.addSubview(dateColumnContentView)
  }
  
  private func setupConstraints() {
    headerScrollView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().offset(leftPadding)
      make.trailing.equalToSuperview()
      make.height.equalTo(topPadding)
    }
    
    mainScrollView.snp.makeConstraints { make in
      make.top.equalTo(headerScrollView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    dateColumnScrollView.snp.makeConstraints { make in
      make.top.equalTo(headerScrollView.snp.bottom)
      make.leading.bottom.equalToSuperview()
      make.width.equalTo(leftPadding)
    }
  }
  
  private func setupGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    contentView.addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Public Methods
  
  func setRecordings(_ recordings: [Recording]) {
    self.recordings = recordings.sorted { $0.createdAt > $1.createdAt }
    calculateTimeRange()
    setNeedsLayout()
    layoutIfNeeded()
    updateContentSize()
    buildHeaderLabels()
    buildRowViews()
    buildDateLabels()
  }
  
  func getRecording(at index: Int) -> Recording? {
    guard index >= 0 && index < recordings.count else { return nil }
    return recordings[index]
  }
  
  // MARK: - Private Methods
  
  private func calculateTimeRange() {
    guard !recordings.isEmpty else {
      startHour = 0
      endHour = 24
      return
    }
    
    let calendar = Calendar.current
    var earliestMinutes = 24 * 60
    var latestMinutes = 0
    
    for recording in recordings {
      let hour = calendar.component(.hour, from: recording.createdAt)
      let minute = calendar.component(.minute, from: recording.createdAt)
      let startMinutes = hour * 60 + minute
      let endMinutes = startMinutes + Int(recording.duration / 60)
      
      earliestMinutes = min(earliestMinutes, startMinutes)
      latestMinutes = max(latestMinutes, endMinutes)
    }
    
    startHour = max(0, earliestMinutes / 60)
    endHour = min(24, max((latestMinutes + 59) / 60, startHour + 2))
  }
  
  private func updateContentSize() {
    let contentHeight = max(CGFloat(recordings.count) * rowHeight, mainScrollView.bounds.height)
    let totalWidth = leftPadding + timelineWidth + rightPadding
    
    contentView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(totalWidth)
      make.height.equalTo(contentHeight)
    }
    
    headerContentView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalToSuperview()
      make.width.equalTo(timelineWidth + rightPadding)
    }
    
    dateColumnContentView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(leftPadding)
      make.height.equalTo(contentHeight)
    }
  }
  
  private func buildHeaderLabels() {
    headerContentView.subviews.forEach { $0.removeFromSuperview() }
    
    let totalHours = endHour - startHour
    for i in 0...totalHours {
      let label = UILabel()
      label.text = String(format: "%02d:00", startHour + i)
      label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
      label.textColor = .white
      headerContentView.addSubview(label)
      
      let xOffset = hourWidth * CGFloat(i)
      label.snp.makeConstraints { make in
        if i == 0 {
          make.leading.equalToSuperview()
        } else if i == totalHours {
          make.trailing.equalTo(headerContentView.snp.leading).offset(xOffset)
        } else {
          make.centerX.equalTo(headerContentView.snp.leading).offset(xOffset)
        }
        make.centerY.equalToSuperview()
      }
    }
    
    let bottomLine = UIView()
    bottomLine.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    headerContentView.addSubview(bottomLine)
    bottomLine.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(0.5)
    }
  }
  
  private func buildRowViews() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
    
    for (index, recording) in recordings.enumerated() {
      let rowView = TimelineRowView(
        recording: recording,
        index: index,
        timelineWidth: timelineWidth,
        startHour: startHour,
        endHour: endHour,
        hourWidth: hourWidth
      )
      rowView.tag = index
      contentView.addSubview(rowView)
      
      rowView.snp.makeConstraints { make in
        make.top.equalToSuperview().offset(CGFloat(index) * rowHeight)
        make.leading.equalToSuperview()
        make.width.equalTo(leftPadding + timelineWidth + rightPadding)
        make.height.equalTo(rowHeight)
      }
    }
  }
  
  private func buildDateLabels() {
    dateColumnContentView.subviews.forEach { $0.removeFromSuperview() }
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "E M/d"
    
    for (index, recording) in recordings.enumerated() {
      let label = UILabel()
      label.text = dateFormatter.string(from: recording.createdAt)
      label.font = .systemFont(ofSize: 13, weight: .medium)
      label.textColor = .white
      dateColumnContentView.addSubview(label)
      
      label.snp.makeConstraints { make in
        make.leading.equalToSuperview().offset(12)
        make.top.equalToSuperview().offset(CGFloat(index) * rowHeight + (rowHeight - 20) / 2)
      }
    }
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: contentView)
    let index = Int(location.y / rowHeight)
    if index >= 0 && index < recordings.count {
      delegate?.timelineGraphView(self, didSelectRecordingAt: index)
    }
  }
}

// MARK: - UIScrollViewDelegate

extension TimelineGraphView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    headerScrollView.contentOffset.x = scrollView.contentOffset.x
    dateColumnScrollView.contentOffset.y = scrollView.contentOffset.y
  }
}
