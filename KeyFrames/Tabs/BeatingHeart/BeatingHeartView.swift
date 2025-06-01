import SwiftUI

struct BeatingHeartValues: Animatable {
	var scale: CGFloat = 1
	var bpm: Float
}

public struct BeatingHeartView: View {
	@State var selectedBPM: Float = 70
	@State var lastAnimationCycle = Date()
	@State var repeatAnimationCycle: Bool = false

	fileprivate enum AnimationStep: CaseIterable {
		case diastole
		case systole

		var scale: CGFloat {
			switch self {
			case .diastole: 0.6
			case .systole: 1
			}
		}

		var window: Double {
			switch self {
			case .diastole: 0.3
			case .systole: 0.6
			}
		}
	}

	public var body: some View {
		ZStack {
			Color.red.opacity(0.2).ignoresSafeArea()

			animatedHeart

			bpmSelector
				.padding(.horizontal, .spacingL)
				.padding(.vertical, .spacingM)
		}
	}

	private var animatedHeart: some View {
		Image(.heart)
		.renderingMode(.template)
		.foregroundStyle(.red)
		.keyframeAnimator(initialValue: BeatingHeartValues(bpm: selectedBPM), trigger: lastAnimationCycle) { content, value in
			content
				.scaleEffect(value.scale)
		} keyframes: { [bpm = selectedBPM] _ in
			KeyframeTrack(\.scale) {
				for step in AnimationStep.allCases {
					switch step {
					case .diastole:
						SpringKeyframe(step.scale, duration: .duration(of: step.window, for: bpm), spring: .snappy)

					case .systole:
						LinearKeyframe(step.scale, duration: .duration(of: step.window, for: bpm))
					}
				}
			}
		}
		.onAppear {
			guard !repeatAnimationCycle else { return }
			lastAnimationCycle = Date()
			repeatAnimationCycle = true
		}
		.onDisappear {
			repeatAnimationCycle = false
		}
		.onChange(of: lastAnimationCycle) {
			guard repeatAnimationCycle else { return }
			Task {
				let sleeptime = TimeInterval.duration(of: .totalAnimationWindow, for: selectedBPM)
				try? await Task.sleep(for: .seconds(sleeptime))
				lastAnimationCycle = Date()
			}
		}
	}

	private var bpmSelector: some View {
		VStack {
			Spacer()

			Text("Beats per minute: \(Int(selectedBPM))")

			Slider(value: $selectedBPM, in: 10...250)
		}
	}
}

extension TimeInterval {
	/// - Parameters:
	///   - window: The window of the animation.
	///   - bpm: How many beats per second should currently be animated.
	/// - Returns: Duration of the step divided by the percentage of beats in a minute.
	/// This means that the duration of the step is longer for lower BPMs and shorter for higher BPMS.
	fileprivate static func duration(of window: Double, for bpm: Float) -> TimeInterval {
		window / (Double(bpm) / 60)
	}
}

private extension CGFloat {
	static let diastoleScale: Self = 0.6
	static let systoleScale: Self = 1
}

private extension Double {
	static let totalAnimationWindow: Self = 1
}
