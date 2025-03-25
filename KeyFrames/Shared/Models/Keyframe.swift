//
//  Track.swift
//  KeyFrames
//
//  Created by Victor Magpali on 16/03/2025.
//

import SwiftUI

public enum Keyframe {
	case linear(curve: UnitCurve = .linear)
	case cubic(startVelocity: CGFloat? = nil, endVelocity: CGFloat? = nil)
	case spring(spring: Spring = .init(), startVelocity: CGFloat? = nil)
}

extension [Keyframe] {
	public func timeline(for totalValue: CGFloat, totalDuration: TimeInterval) -> KeyframeTimeline<CGFloat> {
		return .init(initialValue: 0, content: { trackContent(for: totalValue, totalDuration: totalDuration) })
	}

	@KeyframeTrackContentBuilder<CGFloat>
	public func trackContent(for totalValue: CGFloat, totalDuration: TimeInterval) -> some KeyframeTrackContent<CGFloat> {
		let segmentDuration: TimeInterval = totalDuration / Double(count)
		for indice in indices {
			let track = self[indice]
			let individualValue = (totalValue * CGFloat(indice + 1)) / CGFloat(count)

			switch track {
			case let .linear(curve):
				LinearKeyframe(individualValue, duration: segmentDuration, timingCurve: curve)
			case let .cubic(startVelocity, endVelocity):
				CubicKeyframe(individualValue, duration: segmentDuration, startVelocity: startVelocity, endVelocity: endVelocity)
			case let .spring(spring, startVelocity):
				SpringKeyframe(individualValue, duration: segmentDuration, spring: spring, startVelocity: startVelocity)
			}
		}
	}
}

public enum KeyframeName: String, CaseIterable, Hashable, Identifiable {
	case linear
	case cubic
	case spring
}

public enum LinearUnitCurve: String, CaseIterable, Hashable, Identifiable {
	case linear = "Linear"
	case easeIn = "Ease In"
	case easeOut = "Ease Out"
	case easeInOut = "Ease In Out"
	case circularEaseIn = "Circular Ease In"
	case circularEaseOut = "Circular Ease Out"
	case circularEaseInOut = "Circular Ease In Out"

	public var curve: UnitCurve {
		switch self {
		case .linear: .linear
		case .easeIn: .easeIn
		case .easeOut: .easeOut
		case .easeInOut: .easeInOut
		case .circularEaseIn: .circularEaseIn
		case .circularEaseOut: .circularEaseOut
		case .circularEaseInOut: .circularEaseInOut
		}
	}
}

public enum SpringValue: String, CaseIterable, Hashable, Identifiable {
	case spring
	case bouncy
	case smooth
	case snappy

	public var value: Spring {
		switch self {
		case .spring: .init()
		case .bouncy: .bouncy
		case .smooth: .smooth
		case .snappy: .snappy
		}
	}
}
