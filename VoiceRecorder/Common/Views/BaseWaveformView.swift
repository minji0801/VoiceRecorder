//
//  BaseWaveformView.swift
//  VoiceRecorder
//
//  Created by Arlin Kim on 1/9/26.
//  파형 뷰 공통 베이스 클래스

import UIKit

class BaseWaveformView: UIView {
  
  // MARK: - Constants
  
  let barWidth: CGFloat = 3.0
  let spacing: CGFloat = 4.0
  let padding: CGFloat = 32.0
  let maxBars: Int = 60
  let startX: CGFloat = 16.0
  
  let minBarHeight: CGFloat = 4.0
  let maxHeightRatio: CGFloat = 0.7
  let scalePower: CGFloat = 0.7
  
  var totalBarWidth: CGFloat { barWidth + spacing }
  
  var gradientStartColor: UIColor = .customPurpleDark
  var gradientEndColor: UIColor = .customPurple
  var inactiveColor: UIColor = .customGray
  
  // MARK: - Init
  
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
  
  // MARK: - Drawing Helpers
  
  func prepareContext(_ context: CGContext, in rect: CGRect) {
    context.setFillColor(UIColor.customNavy.cgColor)
    context.fill(rect)
    context.setLineCap(.round)
    context.setLineWidth(barWidth)
  }
  
  func calculateBarHeight(for level: Float, maxHeight: CGFloat) -> CGFloat {
    let scaled = pow(CGFloat(level), 0.7)
    return max(minBarHeight, scaled * maxHeight)
  }
  
  func drawBar(context: CGContext, at x: CGFloat, centerY: CGFloat, height: CGFloat, color: UIColor) {
    context.setStrokeColor(color.cgColor)
    context.move(to: CGPoint(x: x, y: centerY - height / 2))
    context.addLine(to: CGPoint(x: x, y: centerY + height / 2))
    context.strokePath()
  }
  
  func drawPlaceholderBars(in rect: CGRect, context: CGContext) {
    let availableWidth = rect.width - padding
    let barCount = Int(availableWidth / totalBarWidth)
    let centerY = rect.height / 2
    
    context.setLineCap(.round)
    context.setLineWidth(barWidth)
    context.setStrokeColor(UIColor.customGray.cgColor)
    
    for i in 0..<barCount {
      let x = startX + CGFloat(i) * totalBarWidth + barWidth / 2
      context.move(to: CGPoint(x: x, y: centerY - 2))
      context.addLine(to: CGPoint(x: x, y: centerY + 2))
    }
    context.strokePath()
  }
  
  func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
    var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
    
    from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
    to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
    
    return UIColor(
      red: fromR + (toR - fromR) * progress,
      green: fromG + (toG - fromG) * progress,
      blue: fromB + (toB - fromB) * progress,
      alpha: fromA + (toA - fromA) * progress
    )
  }
}
