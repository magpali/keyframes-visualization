//
//  TabBar.swift
//  KeyFrames
//
//  Created by Victor Magpali on 15/03/2025.
//

import SwiftUI

public struct TabBar: View {
	public enum Tab: CaseIterable, Hashable, Identifiable {
		case home
		case timeCurves

		var title: String {
			switch self {
			case .home: "Home"
			case .timeCurves: "Time Curves"
			}
		}

		var image: String {
			switch self {
			case .home: "stars-icon"
			case .timeCurves: "graph-icon"
			}
		}
	}

	let tabs: [Tab]
	@State var selected: Tab

	public init(tabs: [Tab] = Tab.allCases, selected: Tab = .home) {
		self.tabs = tabs
		self.selected = selected
	}

	public var body: some View {
		TabView(selection: $selected) {
			ForEach(tabs) { tab in
				SwiftUI.Tab(tab.title, image: tab.image, value: tab) {
					switch tab {
						case .home: Home()
						case .timeCurves: TimeCurves()
					}
				}
			}
		}
	}
}
