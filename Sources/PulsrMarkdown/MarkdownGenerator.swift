//
//  MarkdownGenerator.swift
//  
//
//  Created by Emil Pedersen on 15/04/2021.
//

import Foundation
import UIKit

public struct MarkdownGenerator {
    public var rules: [MarkdownRule]
    public var keepSpecifiers: Bool
    public var specifierAttributes: [NSAttributedString.Key: Any]
    
    public init(
        rules: [MarkdownRule],
        keepSpecifiers: Bool = false,
        specifierAttributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor._markdownSpecifierForeground, .fontWeight: UIFont.Weight.regular, .obliqueness: 0, .underlineStyle: 0, .strikethroughStyle: 0]) {
        self.rules = rules
        self.keepSpecifiers = keepSpecifiers
        self.specifierAttributes = specifierAttributes
    }
    
    public func generate(string: String, tappedIds: Set<Int>? = nil) -> NSMutableAttributedString {
        let str = NSMutableAttributedString(string: string, attributes: [.foregroundColor: UIColor.label])
        var excluded: [ExcludedRange] = []
        var ids: Int = 0
        for rule in rules {
            apply(rule: rule, in: str, excluding: &excluded, tappedIds: tappedIds, ids: &ids)
        }
        findEscapes(in: str, excluding: &excluded)
        if keepSpecifiers {
            for elem in excluded where elem.reason == .specifier {
                str.addAttributes(specifierAttributes, range: elem.range)
            }
        } else {
            excluded.sort(by: { $0.range.location < $1.range.location })
            var correct = 0
            for elem in excluded where elem.reason == .specifier {
                str.deleteCharacters(in: NSRange(location: elem.range.location - correct, length: elem.range.length))
                correct += elem.range.length
            }
        }
        str.enumerateAttributes(in: NSRange(location: 0, length: str.length)) { attributes, range, stop in
            let weight = attributes[.fontWeight] as? UIFont.Weight ?? .regular
            let size = attributes[.fontSize] as? CGFloat ?? 17
            let style = attributes[.textStyle] as? UIFont.TextStyle ?? .body
            let font: UIFont
            if attributes[.monospaced] as? Bool ?? false {
                font = .monospacedSystemFont(ofSize: size, weight: weight)
            } else {
                font = .systemFont(ofSize: size, weight: weight)
            }
            str.addAttribute(.font, value: UIFontMetrics(forTextStyle: style).scaledFont(for: font), range: range)
        }
        return str
    }
    
    internal func apply(rule: MarkdownRule, in str: NSMutableAttributedString, excluding: inout [ExcludedRange], tappedIds: Set<Int>?, ids: inout Int, startingPos: Int = 0) {
        /// We're not gonna split thru emojis are we're only looking for markdown. we don't risk anything by going full NSString
        let string = str.string as NSString
        var pos = startingPos
        if rule.close == "\n" || rule.close.isEmpty { // handle specially. Starts at the start of a line, lasts the whole block
            guard let start = findLocation(of: rule.open, in: string, excluding: excluding, pos: &pos) else {
                return // zero matches of open, we are finished
            }
            let index = start.location
            if index == 0 || string.character(at: index - 1) == 10 { // '\n', start of line, ok
                let nextNewline = string.range(of: rule.close, range: NSRange(location: start.upperBound, length: string.length - start.upperBound)).location
                let stop = nextNewline == NSNotFound ? string.length : nextNewline
                let range = NSRange(location: start.upperBound, length: stop - start.upperBound)
                str.addAttributes(computeAttributes(rule: rule, tappedIds: tappedIds, ids: &ids), range: range)
                excluding.append(.init(reason: .specifier, range: start))
                if rule.raw {
                    excluding.append(.init(reason: .raw, range: range))
                }
            }
        } else if let start = findLocation(of: rule.open, in: string, excluding: excluding, pos: &pos) {
            let nextNewline = rule.multiline ? NSNotFound : string.range(of: "\n", range: NSRange(location: start.upperBound, length: string.length - start.upperBound)).lowerBound
            if let stop = findLocation(of: rule.close, in: string, excluding: excluding, pos: &pos, until: nextNewline, raw: rule.raw),
               start.upperBound != stop.lowerBound {
                // yay
                let range = NSRange(location: start.upperBound, length: stop.lowerBound - start.upperBound)
                str.addAttributes(computeAttributes(rule: rule, tappedIds: tappedIds, ids: &ids), range: range)
                excluding.append(.init(reason: .specifier, range: start))
                excluding.append(.init(reason: .specifier, range: stop))
                if rule.raw {
                    excluding.append(.init(reason: .raw, range: range))
                }
            } // else, maybe other ones
        } else {
            return // zero matches of open, we are finished
        }
        apply(rule: rule, in: str, excluding: &excluding, tappedIds: tappedIds, ids: &ids, startingPos: pos)
    }
    
    internal func computeAttributes(rule: MarkdownRule, tappedIds: Set<Int>?, ids: inout Int) -> [NSAttributedString.Key: Any] {
        var attributes = rule.attributes
        if let tappedAttributes = rule.tappedAttributes {
            let tapId = ids
            ids += 1
            if tappedIds.map({ $0.contains(tapId) }) ?? true {
                attributes = tappedAttributes
            }
            attributes[.tappableAttributeID] = tapId
        }
        return attributes
    }
    
    internal func findLocation(of sub: String, in str: NSString, excluding: [ExcludedRange], pos: inout Int, until: Int = NSNotFound, raw: Bool = false) -> NSRange? {
        while let found = str.range(of: sub, range: NSRange(location: pos, length: (until == NSNotFound ? str.length : until) - pos)).ifFound {
            pos = found.upperBound
            if raw || checkNotEscaped(at: found.lowerBound, in: str) {
                if !excluding.contains(where: { $0.range.intersection(found) != nil }) {
                    return found
                }
            }
        }
        return nil
    }
    
    internal func checkNotEscaped(at i: Int, in string: NSString) -> Bool {
        guard i > 0 else {
            return true // first position, not escaped
        }
        let index = i - 1
        if string.character(at: index) == 92 { // '\'
            return !checkNotEscaped(at: index, in: string) // check for double escape
        } else {
            return true // all good
        }
    }
    
    internal func findEscapes(in str: NSMutableAttributedString, excluding: inout [ExcludedRange]) {
        let string = str.string as NSString
        var pos = 0
        if let location = findLocation(of: "\\", in: string, excluding: excluding, pos: &pos) {
            excluding.append(.init(reason: .specifier, range: location))
            findEscapes(in: str, excluding: &excluding)
        }
    }
}

extension NSRange {
    var ifFound: NSRange? {
        location == NSNotFound ? nil : self
    }
}

public extension Array where Element == MarkdownRule {
    static let basicInlines: Self = [.code2, .code, .bold, .underline, .striketrough, .italicAsterisk, .italicUnderscore]
    static let headers: Self = [.header1, .header2, .header3]
}

public extension MarkdownGenerator {
    // May change without warning
    static let `default` = MarkdownGenerator(rules: .headers + [.blockquoteUntilEnd, .blockquote, .codeblock] + .basicInlines + [.spoilerReddit, .warning])
    // Just missing codeblocks
    static let discord = MarkdownGenerator(rules: [.blockquoteUntilEnd, .blockquote, .codeblock] + .basicInlines + [.spoilerDiscord])
    
    static let pulsr = MarkdownGenerator(rules: .headers + [.blockquoteUntilEnd, .blockquote, .codeblock] + .basicInlines + [.spoilerDiscord])
    
    func keepingSpecifiers() -> Self {
        var copy = self
        copy.keepSpecifiers = true
        return copy
    }
}

public extension NSAttributedString.Key {
    /// Used internally for spoilers. do not set.
    static let tappableAttributeID = Self("__PulsrMarkdown_tappableAttributeID")
    /// Inset color, no inset (nil) by default
    static let insetColor = Self("__PulsrMarkdown_insetColor")
    /// UIFont.Weight, regular by default
    static let fontWeight = Self("__PulsrMarkdown_fontWeight")
    /// Bool, false by default
    static let monospaced = Self("__PulsrMarkdown_monospaced")
    /// UIFont.TextStyle, body by default
    static let textStyle = Self("__PulsrMarkdown_textStyle")
    /// CGFloat, 17 (body) by default
    static let fontSize = Self("__PulsrMarkdown_fontSize")
}

internal extension MarkdownGenerator {
    struct ExcludedRange {
        var reason: Reason
        var range: NSRange
        
        enum Reason {
            case specifier
            case raw
        }
    }
}
