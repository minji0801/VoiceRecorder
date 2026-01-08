//
//  WaveformView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/8/26.
//

import UIKit

final class WaveformView: UIView {
  
  // MARK: - Properties
  
  var waveColor: UIColor = UIColor(red: 0.6, green: 0.5, blue: 0.9, alpha: 1.0) {
    didSet { setNeedsDisplay() }
  }
  
  var lineWidth: CGFloat = 3.0 {
    didSet { setNeedsDisplay() }
  }
  
  var spacing: CGFloat = 4.0 {
    didSet { setNeedsDisplay() }
  }
  
  private var levels: [Float] = []
  private let maxBars: Int = 60
  
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
    backgroundColor = .clear
    isOpaque = false
    layer.cornerRadius = 12
    clipsToBounds = true
  }
  
  // MARK: - Public Methods
  
  func addLevel(_ level: Float) {
    levels.append(level)
    
    if levels.count > maxBars {
      levels.removeFirst()
    }
    
    setNeedsDisplay()
  }
  
  func reset() {
    levels.removeAll()
    setNeedsDisplay()
  }
  
  func setLevels(_ newLevels: [Float]) {
    levels = newLevels
    setNeedsDisplay()
  }
  
  // MARK: - Drawing
  
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    // Draw background
    let bgColor = UIColor(red: 0.08, green: 0.09, blue: 0.15, alpha: 1.0)
    context.setFillColor(bgColor.cgColor)
    context.fill(rect)
    
    guard !levels.isEmpty else {
      drawPlaceholderBars(in: rect, context: context)
      return
    }
    
    let barWidth = lineWidth
    let totalBarWidth = barWidth + spacing
    let availableWidth = rect.width - 32
    let maxVisibleBars = Int(availableWidth / totalBarWidth)
    
    let visibleLevels: [Float]
    if levels.count > maxVisibleBars {
      visibleLevels = Array(levels.suffix(maxVisibleBars))
    } else {
      visibleLevels = levels
    }
    
    let centerY = rect.height / 2
    let maxHeight = rect.height * 0.7
    
    let startColor = UIColor(red: 0.55, green: 0.45, blue: 0.85, alpha: 1.0)
    let endColor = UIColor(red: 0.65, green: 0.6, blue: 0.95, alpha: 1.0)
    
    context.setLineCap(.round)
    context.setLineWidth(barWidth)
    
    let startX: CGFloat = 16
    
    for (index, level) in visibleLevels.enumerated() {
      let x = startX + CGFloat(index) * totalBarWidth + barWidth / 2
      let progress = CGFloat(index) / CGFloat(max(1, visibleLevels.count - 1))
      let color = interpolateColor(from: startColor, to: endColor, progress: progress)
      
      let scaledLevel = pow(CGFloat(level), 0.6)
      let barHeight = max(4, scaledLevel * maxHeight)
      
      let startY = centerY - barHeight / 2
      let endY = centerY + barHeight / 2
      
      context.setStrokeColor(color.cgColor)
      context.move(to: CGPoint(x: x, y: startY))
      context.addLine(to: CGPoint(x: x, y: endY))
      context.strokePath()
    }
  }
  
  private func drawPlaceholderBars(in rect: CGRect, context: CGContext) {
    let barWidth: CGFloat = 3.0
    let spacing: CGFloat = 4.0
    let totalBarWidth = barWidth + spacing
    let startX: CGFloat = 16
    let availableWidth = rect.width - 32
    let barCount = Int(availableWidth / totalBarWidth)
    let centerY = rect.height / 2
    
    let placeholderColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.5)
    
    context.setLineCap(.round)
    context.setLineWidth(barWidth)
    context.setStrokeColor(placeholderColor.cgColor)
    
    for i in 0..<barCount {
      let x = startX + CGFloat(i) * totalBarWidth + barWidth / 2
      let barHeight: CGFloat = 4
      
      context.move(to: CGPoint(x: x, y: centerY - barHeight / 2))
      context.addLine(to: CGPoint(x: x, y: centerY + barHeight / 2))
    }
    context.strokePath()
  }
  
  private func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
    var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
    
    from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
    to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
    
    let r = fromR + (toR - fromR) * progress
    let g = fromG + (toG - fromG) * progress
    let b = fromB + (toB - fromB) * progress
    let a = fromA + (toA - fromA) * progress
    
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}

