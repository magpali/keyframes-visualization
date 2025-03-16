//
//  TimelineCurvePath.swift
//  KeyFrames
//
//  Created by Victor Magpali on 16/03/2025.
//

import SwiftUI

public struct TimelineCurvePath: View {

	var tracks: [Track] = [.cubic()]

	private func timeline(for totalValue: CGFloat) -> KeyframeTimeline<CGFloat> {
		let duration: TimeInterval = .animationDuration / Double(tracks.count)
		return .init(initialValue: 0, content: {
			for indice in tracks.indices {
				let track = tracks[indice]
				let individualValue = (totalValue * CGFloat(indice + 1)) / CGFloat(tracks.count)

				switch track {
				case let .linear(curve):
					LinearKeyframe(individualValue, duration: duration, timingCurve: curve)
				case let .cubic(startVelocity, endVelocity):
					CubicKeyframe(individualValue, duration: duration, startVelocity: startVelocity, endVelocity: endVelocity)
				case let .spring(spring, startVelocity):
					SpringKeyframe(individualValue, duration: duration, spring: spring, startVelocity: startVelocity)
				}
			}
		})
	}

	public var body: some View {
		GeometryReader { proxy in
			path(width: proxy.size.width, height: proxy.size.height)
				.stroke(lineWidth: 5)
				.foregroundColor(Color.black)
		}
	}

	private func path(width: CGFloat, height: CGFloat) -> Path {
		let timeline = timeline(for: height)
		
		var path = Path()
		
		var currentX: CGFloat = .zero
		var currentY: CGFloat = height
		
		path.move(to: .init(x: currentX, y: currentY))
		
		for i in 1...100 {
			let progress = Double(i) / 100
			let value = timeline.value(progress: progress)
			
			currentX = width * progress
			currentY = height - value
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
		TimelineCurvePath(tracks: [.linear()])

		TimelineCurvePath(tracks: [.cubic()])

		TimelineCurvePath(tracks: [.spring(), .spring()])
	}
	.padding(.horizontal, 32)
	.padding(.vertical, 64)
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(Color.orange.opacity(0.2))
}
