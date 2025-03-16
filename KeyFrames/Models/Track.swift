//
//  Track.swift
//  KeyFrames
//
//  Created by Victor Magpali on 16/03/2025.
//

import SwiftUI

public enum Track {
	case linear(curve: UnitCurve = .linear)
	case cubic(startVelocity: CGFloat? = nil, endVelocity: CGFloat? = nil)
	case spring(spring: Spring = .init(), startVelocity: CGFloat? = nil)
}
