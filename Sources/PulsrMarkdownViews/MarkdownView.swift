//
//  MarkdownView.swift
//
//
//  Created by Emil Pedersen on 16/04/2021.
//

import UIKit
import PulsrMarkdown

open class MarkdownView: UITextView {
    
    public var generator: MarkdownGenerator
    
    public var markdown: String = "" {
        didSet {
            updateMarkdown()
        }
    }
    
    weak var customDrawing: CustomDrawingView!
    
    public init(generator: MarkdownGenerator) {
        self.generator = generator
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontForContentSizeCategory = true
        
        let drawing = CustomDrawingView { [weak self] in
            self?.drawInsetColor()
        }
        drawing.translatesAutoresizingMaskIntoConstraints = false
        addSubview(drawing)
        customDrawing = drawing
        
        NSLayoutConstraint.activate([
            drawing.topAnchor.constraint(equalTo: textInputView.topAnchor),
            drawing.bottomAnchor.constraint(equalTo: textInputView.bottomAnchor),
            drawing.leadingAnchor.constraint(equalTo: textInputView.leadingAnchor),
            drawing.trailingAnchor.constraint(equalTo: textInputView.trailingAnchor),
            drawing.widthAnchor.constraint(equalTo: textInputView.widthAnchor),
            drawing.heightAnchor.constraint(equalTo: textInputView.heightAnchor),
        ])
    }
    
    @available(iOS, deprecated)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func updateMarkdown() {
        attributedText = generator.generate(string: markdown)
        customDrawing.setNeedsDisplay()
    }
    
    open func drawCustomOverlay() {
        drawInsetColor()
    }
    
    open func drawInsetColor() {
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: (attributedText.string as NSString).length), options: []) { attributes, range, stop in
            if let insetColor = attributes[.insetColor] as? UIColor {
                let p1 = self.position(from: self.beginningOfDocument, offset: range.location)!
                let y1 = self.caretRect(for: p1).minY
                let y2 = self.caretRect(for: self.position(from: p1, offset: range.length)!).maxY
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 8, y: y1))
                path.addLine(to: CGPoint(x: 8, y: y2))
                path.lineWidth = 3
                insetColor.setStroke()
                path.stroke()
            }
        }
    }
}

internal class CustomDrawingView: UIView {
    
    var customDrawing: () -> Void
    
    init(customDrawing: @escaping () -> Void) {
        self.customDrawing = customDrawing
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        customDrawing()
    }
}

