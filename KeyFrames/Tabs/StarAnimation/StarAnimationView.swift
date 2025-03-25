//
//  Home.swift
//  KeyFrames
//
//  Created by Victor Magpali on 15/03/2025.
//

import SwiftUI

struct StarAnimationValues: Animatable {
	var pathTravelPercentage: CGFloat = .zero
	var xOffset: CGFloat = .zero
	var rotation: Angle = .degrees(.zero)
	var scale: CGFloat = 1
}

public struct StarAnimationView: View {

	private enum Quadrant {
		case topLeft
		case topRight
		case bottomLeft
		case bottomRight
	}

	@State private var tappedPoint: CGPoint?

	public var body: some View {
		ZStack {
			Color.purple.opacity(0.2).ignoresSafeArea()

			GeometryReader { proxy in
				let rect = proxy.frame(in: .local)
				let point = tappedPoint ?? .zero

//				Circle()
//					.fill(Color.black.opacity(0.2))
//					.frame(width: 8, height: 8)
//					.position(point)
//
//				let path = self.path(for: point, in: rect)
//
//				path.stroke(lineWidth: 5)
//					.foregroundColor(Color.black.opacity(0.2))

				star(for: point, in: rect, isShadow: true)

				star(for: point, in: rect)
			}
			.opacity(tappedPoint != nil ? 1 : .zero)
		}
		.onTapGesture { tappedPoint = $0 }
	}

	@ViewBuilder
	private func star(for point: CGPoint, in rect: CGRect, isShadow: Bool = false) -> some View {
		let path = path(for: point, in: rect)

		Image(.star)
			.resizable()
			.renderingMode(.template)
			.foregroundStyle(isShadow ? Color.black : Color.orange)
			.opacity(isShadow ? 0.3 : 1)
			.frame(width: 64, height: 64)
			.ignoresSafeArea()
			.keyframeAnimator(initialValue: StarAnimationValues(), trigger: point) { content, value in
				content
					.scaleEffect(value.scale)
					.rotationEffect(value.rotation)
					.modifier(
						PathTravel(
							path: path,
							completion: value.pathTravelPercentage,
							startingPoint: path.startingPoint
						)
					)
					.offset(x: value.xOffset, y: isShadow ? 10 : .zero)
			} keyframes: { _ in
				starKeyframes(for: point, in: rect, offsetMultipler: isShadow ? 0.2 : 0.5)
			}
	}

	private func quadrant(for point: CGPoint, in rect: CGRect) -> Quadrant {
		if point.y < rect.midY {
			point.x < rect.midX ? .topLeft : .topRight
		} else {
			point.x < rect.midX ? .bottomLeft : .bottomRight
		}
	}

	private func offset(for point: CGPoint, in rect: CGRect, multiplier: CGFloat) -> CGFloat {
		let tapQuadrant = quadrant(for: point, in: rect)

		let offset = switch tapQuadrant {
		case .topLeft, .bottomLeft: ((rect.maxX - point.x) * multiplier)
		case .topRight, .bottomRight: -(point.x * multiplier)
		}

		return offset
	}

	private func path(for point: CGPoint, in rect: CGRect) -> Path {
		var path = Path()
		let tapQuadrant = quadrant(for: point, in: rect)

		let pathStart: CGPoint = switch tapQuadrant {
		case .topLeft: CGPoint(x: rect.maxX - .pathHorizontalSpacing, y: rect.maxY)
		case .topRight: CGPoint(x: rect.minX + .pathHorizontalSpacing, y: rect.maxY)
		case .bottomLeft: CGPoint(x: rect.maxX - .pathHorizontalSpacing, y: rect.minY)
		case .bottomRight: CGPoint(x: rect.minX + .pathHorizontalSpacing, y: rect.minY)
		}

		path.move(to: pathStart)

		path.addLine(to: point)

		return path
	}

	private func rotationDirecton(for point: CGPoint, in rect: CGRect) -> CGFloat {
		switch quadrant(for: point, in: rect) {
		case .topLeft, .bottomRight: -1
		case .topRight, .bottomLeft: 1
		}
	}

	@KeyframesBuilder<StarAnimationValues>
	func starKeyframes(for point: CGPoint, in rect: CGRect, offsetMultipler: CGFloat) -> some Keyframes<StarAnimationValues> {
		KeyframeTrack(\.pathTravelPercentage) {
			LinearKeyframe(1, duration: 1, timingCurve: .linear)
		}

		KeyframeTrack(\.xOffset) {
			LinearKeyframe(
				offset(for: point, in: rect, multiplier: offsetMultipler),
				duration: 0.8,
				timingCurve: .easeOut
			)

			LinearKeyframe(
				.zero,
				duration: 0.2,
				timingCurve: .circularEaseIn
			)
		}

		KeyframeTrack(\.rotation) {
			LinearKeyframe(
				Angle(degrees: .fullRotation * 3 * rotationDirecton(for: point, in: rect)),
				duration: 1,
			)

			LinearKeyframe(
				Angle(degrees: .fullRotation * 3.6 * rotationDirecton(for: point, in: rect)),
				duration: 3,
			)

			SpringKeyframe(
				Angle(degrees: .fullRotation * 4.2 * rotationDirecton(for: point, in: rect)),
				duration: 0.5,
				spring: .snappy
			)
		}

		KeyframeTrack(\.scale) {
			SpringKeyframe(2, duration: 0.5, spring: .snappy)

			SpringKeyframe(0.5, duration: 0.5, spring: .snappy)

			SpringKeyframe(5, duration: 3, spring: .snappy)

			SpringKeyframe(1, duration: 0.5, spring: .snappy)
		}
	}
}


private extension CGFloat {
	static var pathHorizontalSpacing: Self = 64
	static var fullRotation: Self = 360
}

private extension Path {
	var startingPoint: CGPoint { trimmedPath(from: 0, to: 0.01).currentPoint ?? .zero }
}
