//
//  TimelineCurvePath.swift
//  KeyFrames
//
//  Created by Victor Magpali on 16/03/2025.
//

import SwiftUI

public struct TimelineCurvePath: View {
	var keyframes: [Keyframe] = []

	public var body: some View {
		GeometryReader { proxy in
			path(width: proxy.size.width, height: proxy.size.height)
				.stroke(lineWidth: 5)
				.foregroundColor(Color.black)
		}
	}

	private func path(width: CGFloat, height: CGFloat) -> Path {
		let timeline = keyframes.timeline(for: 1, totalDuration: 2)

		var path = Path()
		
		var currentX: CGFloat = .zero
		var currentY: CGFloat = height
		
		path.move(to: .init(x: currentX, y: currentY))
		
		for i in 1...100 {
			let progress = Double(i) / 100
			let value = timeline.value(progress: progress)
			
			currentX = width * progress
			currentY = height - (height * value)
			let point = CGPoint(x: currentX, y: currentY)

			path.addLine(to: point)
		}
		return path
	}
}

private extension TimeInterval {
	static let animationDuration: Self = 1
}

#Preview {
	VStack(alignment: .center, spacing: 32) {
		TimelineCurvePath(keyframes: [.linear()])

		TimelineCurvePath(keyframes: [.cubic()])

		TimelineCurvePath(keyframes: [.spring(), .spring()])
	}
	.padding(.horizontal, 32)
	.padding(.vertical, 64)
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(Color.orange.opacity(0.2))
}
