//
//  TimeCurve.swift
//  KeyFrames
//
//  Created by Victor Magpali on 15/03/2025.
//

import SwiftUI

struct AnimationValues: Animatable {
	var completion: CGFloat = 0
}

public struct TimeCurves: View {

	@State private var keyframes: [Keyframe] = []
	@State private var selectedKeyframe: KeyframeName = .linear
	@State private var linearUnitCurve: LinearUnitCurve = .linear
	@State private var springValue: SpringValue = .spring
	@State private var startingVelocity: String = "0"
	@State private var endVelocity: String = "0"
	@State private var animationTrigger: Bool = false

	@FocusState private var isTextFieldFocused: Bool

	private var toneGenerator: ToneGenerator = .init()
	@State private var animationTask = Task<Void, Never> { }

	public var body: some View {
		ZStack {
			background

			content
		}
		.onTapGesture { endEditing() }
	}

	private var background: some View {
		Color.green.opacity(.backgroundOpacity).ignoresSafeArea()
	}

	private var content: some View {
		GeometryReader { proxy in
			VStack(alignment: .center, spacing: .spacingM) {
				animatableContent

				curveGraph(of: proxy.size)

				inputs
			}
		}
		.padding(.spacingM)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.onAppear { toneGenerator.startEngine() }
		.onDisappear { toneGenerator.stopEngine() }
	}

	private var animatableContent: some View  {
		GeometryReader { proxy in
			ZStack {
				SquareGrid(lineColor: .gray.opacity(.animationGridOpacity), lineWidth: .animationSquareGridLineWidth, squareSize: .animationSquareGridSize)

				let rect = proxy.frame(in: .local)

				if !animationTrigger {
					circle.position(x: rect.minX, y: rect.midY)
				} else {
					circle
						.keyframeAnimator(initialValue: AnimationValues()) { content, value in
							content.position(
								x: rect.maxX * value.completion,
								y: rect.midY
							)
						} keyframes: { _ in
							KeyframeTrack(\.completion) {
								keyframes.trackContent(for: 1, totalDuration: 2)
							}
						}
				}
			}
		}
		.frame( width: .animatableContentWidth, height: .animatableContentHeight)
	}

	private func curveGraph(of size: CGSize) -> some View {
		ZStack {
			GraphView(lineColor: .black.opacity(.graphLineOpacity), lineWidth: .graphLineWidth)

			TimelineCurvePath(keyframes: keyframes)
				.padding(.spacingM)
		}
		.padding(.spacingS)
		.frame(
			width: size.height * .curvePathHeightPercentage,
			height: size.height * .curvePathHeightPercentage
		)
		.background(Color.white.opacity(.graphBackgroundOpacity))
	}

	private var circle: some View {
		Circle()
			.stroke(lineWidth: .circleLineWidth)
			.fill(Color.orange)
			.foregroundStyle(Color.black)
			.frame(width: .circleDiameter, height: .circleDiameter)
	}

	private var inputs: some View {
		VStack(spacing: .spacingM) {
			keyframePicker

			trackSpecificInputs
				.frame(maxHeight: .infinity)

			trackActions
		}
	}

	private var keyframePicker: some View {
		Picker("Track", selection: $selectedKeyframe) {
			ForEach(KeyframeName.allCases) { keyframeName in
				Text(keyframeName.rawValue.capitalized).tag(keyframeName)
			}
		}
		.pickerStyle(.segmented)
	}

	private var trackSpecificInputs: some View {
		HStack(spacing: .spacingM) {
			switch selectedKeyframe {
			case .linear:
				Picker("Unit Curve", selection: $linearUnitCurve) {
					ForEach(LinearUnitCurve.allCases) { unitCurve in
						Text(unitCurve.rawValue).tag(unitCurve)
					}
				}
				.pickerStyle(.wheel)

			case .cubic:
				VStack {
					Text("Starting Velocity")

					TextField(text: $startingVelocity, label: {})
						.keyboardType(.numberPad)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.focused($isTextFieldFocused)
				}

				VStack {
					Text("End Velocity")

					TextField(text: $endVelocity, label: {})
						.keyboardType(.numberPad)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.focused($isTextFieldFocused)
				}

			case .spring:
				Picker("Unit Curve", selection: $springValue) {
					ForEach(SpringValue.allCases) { springValue in
						Text(springValue.rawValue.capitalized).tag(springValue)
					}
				}
				.pickerStyle(.wheel)
				.frame(width: .springVelocityWidth)

				VStack {
					Text("Starting Velocity")

					TextField(text: $startingVelocity, label: {})
						.keyboardType(.numberPad)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.focused($isTextFieldFocused)
				}
			}
		}
	}

	private var trackActions: some View {
		HStack(spacing: .spacingL) {
			Button(action: addTrack) { buttonLabel("Add") }
			Button(action: resetTracks) { buttonLabel("Reset") }
			Button(action: animate) { buttonLabel("Animate") }
		}
	}

	private func buttonLabel(_ text: String) -> some View {
		Text(text)
			.foregroundStyle(Color.black)
			.padding(.horizontal, .spacingM)
			.padding(.vertical, .spacingS)
			.background(Color.black.opacity(0.2))
			.cornerRadius(8)
	}

	private func addTrack() {
		endEditing()

		switch selectedKeyframe {
		case .linear:
			keyframes.append(.linear(curve: linearUnitCurve.curve))

		case .cubic:
			let numberFormatter = NumberFormatter()
			guard let startVelocity = numberFormatter.number(from: startingVelocity),
					let endVelocity = numberFormatter.number(from: endVelocity)
			else { return }

			keyframes.append(.cubic(startVelocity: CGFloat(truncating: startVelocity), endVelocity: CGFloat(truncating: endVelocity)))

		case .spring:
			let numberFormatter = NumberFormatter()
			guard let startVelocity = numberFormatter.number(from: startingVelocity) else { return }

			keyframes.append(.spring(spring: springValue.value, startVelocity: CGFloat(truncating: startVelocity)))
		}
	}

	private func resetTracks() {
		endEditing()
		animationTrigger = false
		keyframes = []
		toneGenerator.pause()
		animationTask.cancel()
	}

	private func endEditing() {
		isTextFieldFocused = false
		if startingVelocity.isEmpty { startingVelocity = "0" }
		if endVelocity.isEmpty { endVelocity = "0" }
	}

	private func animate() {
		animationTask.cancel()
		animationTask = Task {
			if animationTrigger {
				animationTrigger = false
				try? await Task.sleep(for: .milliseconds(250))
			}

			animationTrigger = true

			toneGenerator.play()

			let timeline = keyframes.timeline(for: 1, totalDuration: 1.75)
			var currentTime: Double = 0
			while Task.isCancelled == false {
				let value = timeline.value(time: currentTime)

				toneGenerator.set(pitch: Float(value))
				try? await Task.sleep(for: .milliseconds(10))
				if currentTime < 1.75 {
					currentTime += 0.01
				} else {
					currentTime = 0
				}
			}
		}
	}
}

private extension CGFloat {
	static let pathStroke: Self = 3

	static let animationHeightPercentage: Self = 0.2
	static let curvePathHeightPercentage: Self = 0.5
	static let inputsHeightPercentage: Self = 0.3

	static let circleDiameter: Self = animatableContentHeight * 0.25
	static let circleLineWidth: Self = 10
	static let animationPathLineWidth: Self = 2

	static let animationSquareGridLineWidth: Self = 1
	static let animationSquareGridSize: Self = 20
	static let animatableContentHeight: Self = animationSquareGridSize * 6
	static let animatableContentWidth: Self = animationSquareGridSize * 15

	static let springVelocityWidth: Self = 220

	static let graphLineWidth: Self = 2
}

private extension Double {
	static let backgroundOpacity: Self = 0.2
	static let animationGridOpacity: Self = 0.2
	static let graphLineOpacity: Self = 0.3
	static let graphBackgroundOpacity: Self = 0.6
}

private extension TimeInterval {
	static let animationDuration: Self = 1
}


#Preview {
	TimeCurves()
}
