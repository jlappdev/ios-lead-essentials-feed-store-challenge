//
//  XCTestCase+MemoryLeakTrackingHelper.swift
//  Tests
//
//  Created by JL Dev on 2/15/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated, but was not. Potential memory leak detected.", file: file, line: line)
		}
	}
}
