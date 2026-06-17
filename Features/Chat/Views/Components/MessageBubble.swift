//
//  MessageBubbleView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation
import SwiftUI

struct MessageBubble: Shape {
    
    private let cornerRadius: CGFloat = 50
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = min(min(cornerRadius, rect.width / 2), min(cornerRadius, rect.height / 2))
        
        path.move(to: .init(x: rect.maxX, y: rect.maxY))
        path.addLine(to: .init(x: rect.minX + radius, y: rect.maxY))
        
        path.addArc(
            center: .init(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        path.addArc(
            center: .init(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(-90),
            clockwise: false
        )
        
        path.addLine(to: .init(x: rect.maxX - radius, y: rect.minY))
        
        path.addArc(
            center: .init(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

