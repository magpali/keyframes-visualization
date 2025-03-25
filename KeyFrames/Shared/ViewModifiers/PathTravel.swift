//
//  Untitled.swift
//  KeyFrames
//
//  Created by Victor Magpali on 31/03/2025.
//

import SwiftUI

struct PathTravel: Animatable, ViewModifier {

	/// The path to travel along
	let path: Path

	/// The total time to interpolate between. The max value should be no higher than 1.
	var completion: CGFloat

	/// The position where the view should start when the path has no currentPoint
	let startingPoint: CGPoint

	var animatableData: CGFloat {
		get { completion }
		set { completion = newValue }
	}

	func body(content: Content) -> some View {
		content
			.position(path.trimmedPath(from: 0.0, to: min(1, completion)).currentPoint ?? startingPoint)
	}
}

public extension View {
	func travel(along path: Path, completion: CGFloat, startingPoint: CGPoint) -> some View {
		modifier(PathTravel(path: path, completion: completion, startingPoint: startingPoint))
	}
}
