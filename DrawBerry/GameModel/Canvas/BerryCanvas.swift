//
//  BerryCanvas.swift
//  DrawBerry
//
//  Created by Hol Yin Ho on 11/3/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//
import PencilKit

class BerryCanvas: UIView, UIGestureRecognizerDelegate, Canvas {
    // Since we do not have reference cycles, we do not need to make the reference to delegate weak
    weak var delegate: CanvasDelegate?
    var isAbleToDraw = true {
        didSet {
            if !isAbleToDraw {
                canvasView.drawingGestureRecognizer.state = .ended
            }
            canvasView.drawingGestureRecognizer.isEnabled = isAbleToDraw
        }
    }

    var canvasView: PKCanvasView
    let palette: BerryPalette
    let background: UIView
    var clearButton: UIButton
    var selectedInkTool: PKInkingTool? {
        palette.selectedInkTool
    }
    var isEraserSelected: Bool {
        palette.isEraserSelected
    }

    var currentCoordinate: CGPoint? {
        let currentState = canvasView.drawingGestureRecognizer.state
        if currentState == .possible || currentState == .began || currentState == .changed {
            return canvasView.drawingGestureRecognizer.location(in: drawingView)
        }
        return nil
    }

    var isClearButtonEnabled: Bool {
        didSet {
            clearButton.isEnabled = isClearButtonEnabled
            clearButton.isHidden = !isClearButtonEnabled
        }
    }

    var isUndoButtonEnabled: Bool = true {
        didSet {
            palette.isUndoButtonEnabled = isUndoButtonEnabled
        }
    }

    var drawing: PKDrawing {
        canvasView.drawing
    }
    var history: [PKDrawing] = []
    var numberOfStrokes: Int = 0

    var drawingView: UIView? {
        let nestedSubviews = canvasView.subviews.map { $0.subviews }
        var allSubviews: [UIView] = []
        nestedSubviews.forEach { allSubviews += $0 }
        let dgrView = allSubviews.filter { $0 == canvasView.drawingGestureRecognizer.view }
        if dgrView.count != 1 {
            return nil
        }
        return dgrView[0]
    }

    func undo() {
        canvasView.drawing = delegate?.undo(on: self) ?? PKDrawing()
    }

    /// Creates a `Canvas` with the given bounds.
    static func createCanvas(within bounds: CGRect) -> Canvas? {
        if outOfBounds(bounds: bounds) {
            return nil
        }
        return BerryCanvas(frame: bounds)
    }

    /// Sets the `PKTool` of the canvas to the given tool.
    func setTool(to tool: PKTool) {
        canvasView.tool = tool
    }

    /// Checks if the given bounds is within the acceptable bounds.
    private static func outOfBounds(bounds: CGRect) -> Bool {
        bounds.width < BerryConstants.minimumCanvasWidth || bounds.height < BerryConstants.minimumCanvasHeight
    }

    override init(frame: CGRect) {
        palette = BerryCanvas.createPalette(within: frame)
        canvasView = BerryCanvas.createCanvasView(within: frame)
        background = BerryCanvas.createBackground(within: frame)
        clearButton = BerryCanvas.createClearButton(within: frame)
        isClearButtonEnabled = true

        super.init(frame: frame)
        bindGestureRecognizers()
        addComponentsToCanvas()
    }

    required init?(coder: NSCoder) {
        nil
    }

    /// Binds the required gesture recognizers to the views in the `BerryCanvas`.
    private func bindGestureRecognizers() {
        clearButton.addTarget(self, action: #selector(clearButtonTap), for: .touchUpInside)
        let draw = UIPanGestureRecognizer(target: self, action: #selector(handleDraw(recognizer:)))
        draw.delegate = self
        drawingView?.addGestureRecognizer(draw)
    }

    /// Tracks the state of the drawing and update the history when the stroke has ended.
    @objc func handleDraw(recognizer: UIPanGestureRecognizer) {
        delegate?.handleDraw(recognizer: recognizer, canvas: self)
    }

    /// Populate the canvas with the required components.
    private func addComponentsToCanvas() {
        addSubview(background)
        addSubview(canvasView)
        addSubview(palette)
        addSubview(clearButton)
    }

    /// Creates the background with the given bounds.
    private static func createBackground(within bounds: CGRect) -> UIView {
        let background = UIImageView(frame: getBackgroundRect(within: bounds))
        background.image = BerryConstants.paperBackgroundImage
        return background
    }

    /// Creates the canvas view with the given bounds.
    private static func createCanvasView(within bounds: CGRect) -> PKCanvasView {
        let newCanvasView = PKCanvasView(frame: getCanvasRect(within: bounds))
        newCanvasView.allowsFingerDrawing = true
        newCanvasView.isOpaque = false
        newCanvasView.isUserInteractionEnabled = true
        return newCanvasView
    }

    /// Creates the palette with the given bounds.
    private static func createPalette(within bounds: CGRect) -> BerryPalette {
        let newPalette = BerryPalette(frame: getPalatteRect(within: bounds))
        initialise(palette: newPalette)
        return newPalette
    }

    /// Initialises the palette with the default colors.
    private static func initialise(palette: BerryPalette) {
        palette.add(color: UIColor.black)
        palette.add(color: UIColor.blue)
        palette.add(color: UIColor.red)
        palette.selectFirstColor()
    }

    /// Creates the clear button with the given bounds.
    private static func createClearButton(within bounds: CGRect) -> UIButton {
        let button = UIButton(frame: getClearButtonRect(within: bounds))
        let icon = BerryConstants.deleteIcon
        button.setImage(icon, for: .normal)
        return button
    }

    /// Clears the canvas when the clear button is tapped.
    @objc func clearButtonTap() {
        canvasView.drawing = PKDrawing()
        delegate?.clear(canvas: self)
    }

    private static func getClearButtonRect(within bounds: CGRect) -> CGRect {
        let size = CGSize(width: BerryConstants.buttonRadius, height: BerryConstants.buttonRadius)
        let origin = CGPoint(
            x: bounds.width - BerryConstants.buttonRadius - BerryConstants.canvasPadding,
            y: BerryConstants.canvasPadding)
        return CGRect(origin: origin, size: size)
    }

    private static func getCanvasRect(within bounds: CGRect) -> CGRect {
        let size = CGSize(width: bounds.width, height: bounds.height - BerryConstants.paletteHeight)
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: size)
    }

    private static func getPalatteRect(within bounds: CGRect) -> CGRect {
        let size = CGSize(width: bounds.width, height: BerryConstants.paletteHeight)
        let origin = CGPoint(x: 0, y: bounds.height - BerryConstants.paletteHeight)
        return CGRect(origin: origin, size: size)
    }

    private static func getBackgroundRect(within bounds: CGRect) -> CGRect {
        CGRect(origin: CGPoint.zero, size: bounds.size)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
