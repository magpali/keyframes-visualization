//
//  Hashable+Identifiable.swift
//  KeyFrames
//
//  Created by Victor Magpali on 15/03/2025.
//

import Foundation

extension Hashable where Self: Identifiable {
	public var id: Int { hashValue }
}
