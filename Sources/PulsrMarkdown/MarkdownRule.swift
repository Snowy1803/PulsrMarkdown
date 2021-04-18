//
//  MarkdownRule.swift
//
//
//  Created by Emil Pedersen on 15/04/2021.
//

import Foundation
import UIKit

public struct MarkdownRule {
    /// the open tag
    public var open: String
    /// the close tag
    public var close: String
    /// the attributes to add to the content
    public var attributes: [NSAttributedString.Key: Any]
    /// the attributes to add to the content if it has been tapped. if nil, there is no tap detection
    public var tappedAttributes: [NSAttributedString.Key: Any]?
    /// if true, the content isn't parsed for markdown. the rule must be in the first in the list. this also disables the '\' escape for the close tag.
    public var raw: Bool = false
    
    public init(open: String, close: String, attributes: [NSAttributedString.Key : Any], tappedAttributes: [NSAttributedString.Key : Any]? = nil, raw: Bool = false) {
        self.open = open
        self.close = close
        self.attributes = attributes
        self.tappedAttributes = tappedAttributes
        self.raw = raw
    }
}

public extension MarkdownRule {
    static let bold = MarkdownRule(
        open: "**",
        close: "**",
        attributes: [.fontWeight: UIFont.Weight.bold]
    )
    static let italicAsterisk = MarkdownRule(
        open: "*",
        close: "*",
        attributes: [.obliqueness: 0.2]
    )
    static let italicUnderscore = MarkdownRule(
        open: "_",
        close: "_",
        attributes: [.obliqueness: 0.2]
    )
    static let spoilerReddit = MarkdownRule(
        open: ">!",
        close: "!<",
        attributes: .spoiler,
        tappedAttributes: .spoilerRevealed
    )
    static let spoilerDiscord = MarkdownRule(
        open: "||",
        close: "||",
        attributes: .spoiler,
        tappedAttributes: .spoilerRevealed
    )
    static let underline = MarkdownRule(
        open: "__",
        close: "__",
        attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
    )
    static let striketrough = MarkdownRule(
        open: "~~",
        close: "~~",
        attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
    )
    static let warning = MarkdownRule(
        open: "/!\\",
        close: "/!\\",
        attributes: [.foregroundColor: UIColor.systemRed]
    )
    static let code = MarkdownRule(
        open: "`",
        close: "`",
        attributes: .inlineCode,
        raw: true
    )
    static let code2 = MarkdownRule(
        open: "``",
        close: "``",
        attributes: .inlineCode,
        raw: true
    )
    static let blockquote = MarkdownRule(
        open: "> ",
        close: "\n",
        attributes: .blockquote
    )
    
    static let blockquoteUntilEnd = MarkdownRule(
        open: ">>> ",
        close: "",
        attributes: .blockquote
    )
}

public extension MarkdownRule {
    static let header1 = MarkdownRule(
        open: "# ",
        close: "\n",
        attributes: [.textStyle: UIFont.TextStyle.title1, .fontSize: 28 as CGFloat]
    )
    static let header2 = MarkdownRule(
        open: "## ",
        close: "\n",
        attributes: [.textStyle: UIFont.TextStyle.title2, .fontSize: 22 as CGFloat]
    )
    static let header3 = MarkdownRule(
        open: "### ",
        close: "\n",
        attributes: [.textStyle: UIFont.TextStyle.title3, .fontSize: 20 as CGFloat]
    )
}

extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    
    static let spoiler: Self = [.backgroundColor: UIColor.systemGray2, .foregroundColor: UIColor.systemGray2]
    static let spoilerRevealed: Self = [.backgroundColor: UIColor.systemGray3, .foregroundColor: UIColor.label]
    
    static let inlineCode: Self = [.monospaced: true, .backgroundColor: UIColor.secondarySystemBackground]
    
    static let blockquote: Self = [.paragraphStyle: {
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 15
        style.headIndent = 15
        style.paragraphSpacing = 3
        style.paragraphSpacingBefore = 3
        return style
    }(), .insetColor: UIColor.systemGray2]
}
