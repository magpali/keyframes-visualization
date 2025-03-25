import SwiftUI

struct BeatingHeartValues: Animatable {
	var scale: CGFloat = 1
}

public struct BeatingHeartView: View {

	private enum Quadrant {
		case topLeft
		case topRight
		case bottomLeft
		case bottomRight
	}

	@State private var tappedPoint: CGPoint?

	public var body: some View {
		ZStack {
			Color.orange.opacity(0.2).ignoresSafeArea()
		}
	}
}

private extension CGFloat {
	static let diastoleScale: Self = 1.5
	static let systoleScale: Self = 0.7
}
