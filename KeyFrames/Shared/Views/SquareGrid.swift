//
//  SquareGrid.swift
//  KeyFrames
//
//  Created by Victor Magpali on 26/03/2025.
//

import SwiftUI

public struct SquareGrid: View {
	let lineColor: Color
	let lineWidth: CGFloat
	let squareSize: CGFloat

	public var body: some View {
		GeometryReader { proxy in
			horizontalLines(for: proxy.size)
				.stroke(lineWidth: lineWidth)
				.foregroundStyle(lineColor)

			verticalLines(for: proxy.size)
				.stroke(lineWidth: lineWidth)
				.foregroundStyle(lineColor)
		}
	}

	private func verticalLines(for size: CGSize) -> Path {
		var path = Path()

		var currentX: CGFloat = .zero

		while currentX <= size.width {
			path.move(to: CGPoint(x: currentX, y: .zero))
			path.addLine(to: CGPoint(x: currentX, y: size.height))

			currentX += squareSize
		}

		return path
	}

	private func horizontalLines(for size: CGSize) -> Path {
		var path = Path()

		var currentY: CGFloat = .zero

		while currentY <= size.height {
			path.move(to: CGPoint(x: .zero, y: currentY))
			path.addLine(to: CGPoint(x: size.width, y: currentY))

			currentY += squareSize
		}

		return path
	}
}
