//
//  MarkdownEditorView.swift
//  
//
//  Created by Emil Pedersen on 16/04/2021.
//

import UIKit
import PulsrMarkdown

open class MarkdownEditorView: MarkdownView {
    
    public override init(generator: MarkdownGenerator) {
        super.init(generator: generator.keepingSpecifiers())
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @available(iOS, deprecated)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func updateMarkdown() {
        let range = selectedRange
        attributedText = generator.generate(string: markdown)
        selectedRange = range // avoid jumping, we know only attributes changed
    }
    
    @objc open func textDidChange(_ notification: Notification) {
        markdown = attributedText.string
    }
    
    open override func drawInsetColor() { }
}
