//
//  TabBar.swift
//  KeyFrames
//
//  Created by Victor Magpali on 15/03/2025.
//

import SwiftUI

public struct TabBar: View {
	public enum Tab: CaseIterable, Hashable, Identifiable {
		case starAnimation
		case beatingHeart
		case timeCurves

		var title: String {
			switch self {
			case .beatingHeart: "Heart"
			case .starAnimation: "Star"
			case .timeCurves: "Time Curves"
			}
		}

		var image: String {
			switch self {
			case .beatingHeart: "heart.circle"
			case .starAnimation: "star.circle"
			case .timeCurves: "eye.circle"
			}
		}
	}

	let tabs: [Tab]
	@State var selected: Tab

	public init(tabs: [Tab] = .defaultTabs, selected: Tab = .starAnimation) {
		self.tabs = tabs
		self.selected = selected
	}

	public var body: some View {
		TabView(selection: $selected) {
			ForEach(tabs) { tab in
				SwiftUI.Tab(tab.title, image: tab.image, value: tab) {
					switch tab {
						case .starAnimation: StarAnimationView().tabBarRoot()
						case .beatingHeart: BeatingHeartView().tabBarRoot()
						case .timeCurves: TimeCurves().tabBarRoot()
					}
				}
			}
		}
	}
}

extension [TabBar.Tab] {
	public static let defaultTabs: Self = [.starAnimation, .timeCurves]
}

private struct TabBarModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.toolbarBackground(.ultraThinMaterial, for: .tabBar)
			.toolbarBackgroundVisibility(.visible, for: .tabBar)
	}
}

private extension View {
	func tabBarRoot() -> some View {
		modifier(TabBarModifier())
	}
}
