//
//  TimelineRowView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//  녹음 항목 행 뷰

import UIKit

final class TimelineRowView: UIView {
  
  private let recording: Recording
  private let timelineWidth: CGFloat
  private let startHour: Int
  private let endHour: Int
  private let hourWidth: CGFloat
  
  private let leftPadding: CGFloat = 70
  private let barHeight: CGFloat = 28
  
  init(recording: Recording, index: Int, timelineWidth: CGFloat, startHour: Int, endHour: Int, hourWidth: CGFloat) {
    self.recording = recording
    self.timelineWidth = timelineWidth
    self.startHour = startHour
    self.endHour = endHour
    self.hourWidth = hourWidth
    super.init(frame: .zero)
    backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: recording.createdAt)
    let minute = calendar.component(.minute, from: recording.createdAt)
    
    let hoursFromStart = CGFloat(hour - startHour) + CGFloat(minute) / 60.0
    let barStartX = leftPadding + (hourWidth * hoursFromStart)
    
    let durationHours = CGFloat(recording.duration) / 3600.0
    var barWidth = hourWidth * durationHours
    barWidth = max(barWidth, 60)
    
    let barY = (rect.height - barHeight) / 2
    let barRect = CGRect(x: barStartX, y: barY, width: barWidth, height: barHeight)
    
    let path = UIBezierPath(roundedRect: barRect, cornerRadius: 6)
    context.saveGState()
    path.addClip()
    
    let colors = [UIColor.customPurpleDark.cgColor, UIColor.customPurple.cgColor]
    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0]) {
      context.drawLinearGradient(gradient, start: CGPoint(x: barRect.minX, y: 0), end: CGPoint(x: barRect.maxX, y: 0), options: [])
    }
    context.restoreGState()
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    let timeString = timeFormatter.string(from: recording.createdAt)
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold),
      .foregroundColor: UIColor.white
    ]
    let timeSize = timeString.size(withAttributes: attrs)
    
    if barWidth > timeSize.width + 16 {
      timeString.draw(at: CGPoint(x: barStartX + 8, y: barY + (barHeight - timeSize.height) / 2), withAttributes: attrs)
      
      let endTime = recording.createdAt.addingTimeInterval(recording.duration)
      let durationString = timeFormatter.string(from: endTime)
      let durationSize = durationString.size(withAttributes: attrs)
      if barWidth > timeSize.width + durationSize.width + 32 {
        durationString.draw(at: CGPoint(x: barStartX + barWidth - durationSize.width - 8, y: barY + (barHeight - durationSize.height) / 2), withAttributes: attrs)
      }
    }
    
    context.setStrokeColor(UIColor.white.withAlphaComponent(0.05).cgColor)
    context.setLineWidth(0.5)
    
    let hoursInRange = endHour - startHour
    for i in 0...hoursInRange {
      let x = leftPadding + (hourWidth * CGFloat(i))
      context.move(to: CGPoint(x: x, y: 0))
      context.addLine(to: CGPoint(x: x, y: rect.height))
      context.strokePath()
    }
    
    context.move(to: CGPoint(x: leftPadding, y: rect.height - 0.5))
    context.addLine(to: CGPoint(x: leftPadding + timelineWidth, y: rect.height - 0.5))
    context.strokePath()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    alpha = 0.7
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    alpha = 1.0
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    alpha = 1.0
  }
}
