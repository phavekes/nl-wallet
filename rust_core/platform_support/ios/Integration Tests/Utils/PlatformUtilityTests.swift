//
//  PlatformUtilityTests.swift
//  Integration Tests
//
//  Created by The Wallet Developers on 31/03/2023.
//

import Foundation

import XCTest
@testable import PlatformSupport

final class PlatformUtilityTests: XCTestCase {
    func testUrlForAppSupportDirectory() throws {
        let url = try PlatformUtility.urlForAppSupportDirectory()

        XCTAssert(url.isFileURL, "URL should be a file URL")
        XCTAssertGreaterThan(url.path.count, 0, "URL path should not be an empty string")
    }
}
