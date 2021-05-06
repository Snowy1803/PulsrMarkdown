//
//  MarkdownRenderedTextView.swift
//  
//
//  Created by Emil Pedersen on 16/04/2021.
//

import UIKit
import PulsrMarkdown

open class MarkdownRenderedTextView: MarkdownView, UIGestureRecognizerDelegate {
    
    public var revealed: Set<Int> = []
    
    public override init(generator: MarkdownGenerator) {
        super.init(generator: generator)
        isEditable = false
        allowsEditingTextAttributes = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRender))
        tap.cancelsTouchesInView = false // doesn't do anything...
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    @available(iOS, deprecated)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func didTapRender(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended,
              let position = closestPosition(to: sender.location(in: textInputView)),
              position != endOfDocument else {
            return
        }
        becomeFirstResponder()
        let pos = offset(from: beginningOfDocument, to: position)
        if let id = attributedText.attribute(.tappableAttributeID, at: pos, effectiveRange: nil) as? Int {
            revealed.insert(id)
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [self] in
                updateMarkdown()
            }, completion: nil)
        }
    }
    
    open override func generateAttributedText() -> NSAttributedString {
        generator.generate(string: markdown, tappedIds: revealed)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // opening links and revealing spoilers should both work
    }
}
