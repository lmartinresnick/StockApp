//
//  Haptic.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import UIKit

private func hapticFeedbackDefaultSuccess() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.success)
}

private func hapticFeedbackImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

enum Haptic {
    static func onChangeAppColorScheme() {
        hapticFeedbackDefaultSuccess()
    }
    
    static func onShowGraphIndicator() {
        hapticFeedbackImpact(style: .heavy)
    }
    
    static func onChangeTimeMode() {
        hapticFeedbackImpact(style: .light)
    }
    
    static func onChangeLineSegment() {
        hapticFeedbackImpact(style: .light)
    }
}
