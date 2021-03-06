//
//  BerryCanvasTest.swift
//  DrawBerryTests
//
//  Created by Hol Yin Ho on 21/3/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import XCTest
import PencilKit
@testable import DrawBerry

class BerryCanvasTest: XCTestCase {
    var canvas: BerryCanvas!

    override func setUp() {
        continueAfterFailure = false
        canvas = BerryCanvas.createCanvas(
            within: CGRect(origin: CGPoint.zero, size: CGSize(width: 500, height: 500))) as? BerryCanvas
        //canvas.delegate = self
        super.setUp()
    }

    func testInitialise() {
        XCTAssertEqual(canvas.numberOfStrokes, 0)
        XCTAssertTrue(canvas.history.isEmpty)
        XCTAssertEqual(canvas.drawing.dataRepresentation().count, PKDrawing().dataRepresentation().count)
    }

    func testSelectInk() {
        let blueMedium = createInkTool(with: BerryConstants.berryBlue, stroke: Stroke.medium)
        canvas.select(tool: blueMedium)
        XCTAssertTrue(canvas.tool is PKInkingTool)
        guard let blueInkTool = canvas.tool as? PKInkingTool else {
            XCTFail("Tool should be a PKInkingTool")
            return
        }
        XCTAssertEqual(blueInkTool.color, blueMedium.color)
        XCTAssertEqual(blueInkTool.width, blueMedium.width)

        let redThick = createInkTool(with: BerryConstants.berryRed, stroke: Stroke.thick)
        canvas.select(tool: redThick)
        XCTAssertTrue(canvas.tool is PKInkingTool)
        guard let redInkTool = canvas.tool as? PKInkingTool else {
            XCTFail("Tool should be a PKInkingTool")
            return
        }
        XCTAssertEqual(redInkTool.color, redThick.color)
        XCTAssertEqual(redInkTool.width, redThick.width)

        let doesNotExist = createInkTool(with: UIColor.purple, stroke: Stroke.medium)
        canvas.select(tool: doesNotExist) // Should not be selected
        XCTAssertTrue(canvas.tool is PKInkingTool)
        XCTAssertEqual(redInkTool.color, redThick.color)
        XCTAssertEqual(redInkTool.width, redThick.width)
    }

    func testSelectEraser() {
        let eraser = PKEraserTool(PKEraserTool.EraserType.vector)
        canvas.select(tool: eraser)
        XCTAssertTrue(canvas.tool is PKEraserTool)
        guard let sampleEraser = canvas.tool as? PKEraserTool else {
            XCTFail("Tool should be a PKEraserTool")
            return
        }
        XCTAssertEqual(eraser.eraserType, sampleEraser.eraserType)
    }

    func testSelectInkThenEraser() {
        let blueMedium = createInkTool(with: BerryConstants.berryBlue, stroke: Stroke.medium)
        canvas.select(tool: blueMedium)
        XCTAssertTrue(canvas.tool is PKInkingTool)
        guard let blueInkTool = canvas.tool as? PKInkingTool else {
            XCTFail("Tool should be a PKInkingTool")
            return
        }
        XCTAssertEqual(blueInkTool.color, blueMedium.color)
        XCTAssertEqual(blueInkTool.width, blueMedium.width)
        let eraser = PKEraserTool(PKEraserTool.EraserType.vector)
        canvas.select(tool: eraser)
        XCTAssertTrue(canvas.tool is PKEraserTool)
        guard let sampleEraser = canvas.tool as? PKEraserTool else {
            XCTFail("Tool should be a PKEraserTool")
            return
        }
        XCTAssertEqual(eraser.eraserType, sampleEraser.eraserType)
    }

    func testRandomiseInkTool() {
        canvas.randomiseInkTool()
        let tool = canvas.tool
        XCTAssertTrue(tool is PKInkingTool || tool is PKEraserTool)
        // Test if random tool is from palette. If it can be selected, then it is in.
        canvas.select(tool: tool)
        if tool is PKInkingTool {
            guard let randomTool = tool as? PKInkingTool else {
                XCTFail("Tool should be a PKInkingTool")
                return
            }
            guard let currentTool = canvas.tool as? PKInkingTool else {
                XCTFail("Tool should be a PKInkingTool")
                return
            }
            XCTAssertEqual(currentTool.color, randomTool.color)
            XCTAssertEqual(currentTool.width, randomTool.width)
        }
        if tool is PKEraserTool {
            guard let randomTool = tool as? PKEraserTool else {
                XCTFail("Tool should be a PKEraserTool")
                return
            }
            guard let currentTool = canvas.tool as? PKEraserTool else {
                XCTFail("Tool should be a PKEraserTool")
                return
            }
            XCTAssertEqual(randomTool.eraserType, currentTool.eraserType)
        }
    }

}
extension BerryCanvasTest {
    private func createInkTool(with color: UIColor, stroke: Stroke) -> PKInkingTool {
        let defaultInkType = PKInkingTool.InkType.pen
        return PKInkingTool(defaultInkType, color: color, width: stroke.rawValue)
    }

}
