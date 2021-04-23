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
    
    /// Updates the markdown. Do not call directly, change the `markdown` property to trigger it.
    open func updateMarkdown() {
        attributedText = generator.generate(string: markdown)
        customDrawing.setNeedsDisplay()
    }
    
    /// Draws the custom overlay over the text. Currently only calls `drawInsetColor`
    open func drawCustomOverlay() {
        drawInsetColor()
    }
    
    /// Draws the blockquote inset. Override it to do nothing to disable
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
    
    /// Toggles the given inline markdown rule for the selected text
    public func toggleRule(_ rule: MarkdownRule) {
        toggleRule(open: rule.open, close: rule.close, openCheck: rule.open, closeCheck: rule.close)
    }
    
    internal func toggleRule(open: String, close: String, openCheck: String, closeCheck: String) {
        let text = self.text as NSString
        let upper = selectedRange.upperBound
        let lower = selectedRange.lowerBound
        
        let closeRange = NSRange(location: upper, length: (closeCheck as NSString).length)
        if closeRange.upperBound <= text.length,
           text.substring(with: closeRange) == closeCheck {
            textStorage.replaceCharacters(in: closeRange, with: "") // already there, remove
        } else {
            textStorage.replaceCharacters(in: NSRange(location: upper, length: 0), with: close)
        }
        
        let openCheckLen = (openCheck as NSString).length
        let openRange = NSRange(location: lower - openCheckLen, length: openCheckLen)
        if openRange.location >= 0,
           text.substring(with: openRange) == openCheck {
            textStorage.replaceCharacters(in: openRange, with: "") // already there, remove
            selectedRange = NSRange(location: lower - openCheckLen, length: upper - lower)
        } else {
            textStorage.replaceCharacters(in: NSRange(location: lower, length: 0), with: open)
            selectedRange = NSRange(location: lower + (open as NSString).length, length: upper - lower)
        }
        
        markdown = self.text
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let controller = UIMenuController.shared
        if action == #selector(toggleBoldface),
           controller.menuItems?.contains(where: { $0.action == action }) ?? false {
            controller.menuItems?.append(contentsOf: additionalFormattingOptions)
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    /// None by default. Override to add additional rules, such as Strikethrough and Spoiler
    open var additionalFormattingOptions: [UIMenuItem] {
        []
    }
}

extension MarkdownView {
    open override func toggleItalics(_ sender: Any?) {
        toggleRule(.italicAsterisk)
    }
    
    open override func toggleBoldface(_ sender: Any?) {
        toggleRule(.bold)
    }
    
    open override func toggleUnderline(_ sender: Any?) {
        toggleRule(.underline)
    }
    
    @objc open func toggleStrikethrough(_ sender: Any?) {
        toggleRule(.striketrough)
    }
    
    @objc open func toggleSpoilerDiscord(_ sender: Any?) {
        toggleRule(.spoilerDiscord)
    }
    
    @objc open func toggleSpoilerReddit(_ sender: Any?) {
        toggleRule(.spoilerDiscord)
    }
    
    @objc open func cycleCodeStyle(_ sender: Any?) {
        toggleRule(open: "`", close: "`", openCheck: "```", closeCheck: "```")
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

