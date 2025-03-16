//
//  TimeCurve.swift
//  KeyFrames
//
//  Created by Victor Magpali on 15/03/2025.
//

import SwiftUI

/// The animatable properties to provide to the Keyframe Animator
struct AnimationValues {
	var completion: CGFloat = 0
}

public struct TimeCurves: View {

	@State var tracks: [Track] = [.cubic()]

	public var body: some View {
		ZStack {
			background

			content
		}
	}

	private var background: some View {
		Color.green.opacity(0.2).ignoresSafeArea()
	}

	private var content: some View {
		GeometryReader { proxy in
			VStack(alignment: .center) {
				animation(for: proxy.size.height * .animationHeightPercentage)

				TimelineCurvePath(tracks: [.cubic()])
					.frame(width: proxy.size.height * .curvePathHeightPercentage, height: proxy.size.height * .curvePathHeightPercentage)
					.background(Color.white)

				inputs
					.frame(height: proxy.size.height * .inputsHeightPercentage)
			}
			.padding(.horizontal, .horizontalPadding)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}

	private func animation(for height: CGFloat) -> some View  {
		ZStack(alignment: .bottom) {

			Circle()
				.stroke(lineWidth: 10)
				.fill(Color.orange)
				.foregroundStyle(Color.black)
				.frame(width: height * 0.25, height: height * 0.25)
		}
		.frame(height: height)
	}

	private var inputs: some View {
		VStack {
			Button {
				print("hu3 hu3 hu3")
			} label: {
				Text("Hue Three Times")
			}
		}
	}
}

private extension CGFloat {
	static let pathStroke: Self = 3

	static let horizontalPadding: Self = 32
	static let itemMinSize: Self = 64

	static let animationHeightPercentage: Self = 0.5
	static let curvePathHeightPercentage: Self = 0.2
	static let inputsHeightPercentage: Self = 0.3
}

private extension TimeInterval {
	static let animationDuration: Self = 1
}


#Preview {
	TimeCurves()
}
