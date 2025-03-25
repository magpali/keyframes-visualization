//
//  GraphView.swift
//  KeyFrames
//
//  Created by Victor Magpali on 07/04/2025.
//

import SwiftUI

public struct GraphView: View {
	let lineColor: Color
	let lineWidth: CGFloat

	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				let rect = proxy.frame(in: .local)
				let xPath = xPath(in: rect)

				xPath.stroke(lineWidth: lineWidth)
					.foregroundStyle(lineColor)

				let yPath = yPath(in: rect)

				yPath.stroke(lineWidth: lineWidth)
					.foregroundStyle(lineColor)

				Text("value")
					.rotationEffect(.degrees(-90))
					.position(x: rect.minX + .spacingXS, y: rect.minY + .spacingM)
					.foregroundStyle(lineColor)

				Text("time")
					.position(x: rect.maxX - .spacingM, y: rect.maxY - .spacingXS)
					.foregroundStyle(lineColor)
			}
		}
	}

	private func xPath(in rect: CGRect) -> Path {
		var path = Path()

		path.move(to: .init(x: rect.minX + .spacingM, y: rect.minY))
		path.addLine(to: .init(x: rect.minX + .spacingM, y: rect.maxY))

		return path
	}

	private func yPath(in rect: CGRect) -> Path {
		var path = Path()

		path.move(to: .init(x: rect.minX, y: rect.maxY - .spacingM))
		path.addLine(to: .init(x: rect.maxX, y: rect.maxY - .spacingM))

		return path
	}
}
