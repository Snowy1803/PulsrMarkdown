# PulsrMarkdown

Provides a markdown to NSAttributedString lightweight converter. Requires UIKit, and works on iOS 13+, Mac Catalyst 13+ and watchOS 6+.

It also provides `UIView`s to show and edit markdown on iOS (with special support for spoilers).

Supports: 
 - bold, italic, underline, strikethrough, spoilers, code (inline)
 - blockquotes, header titles, code (blocks)


## Get started

If you want to use it with UIKit, `import PulsrMarkdownViews` and use `MarkdownEditorView(generator:)` to make an editable markdown text view, and `MarkdownRenderedTextView(generator:)` to show the result. You pass a generator, which include the set of `MarkdownRule` to apply (replacements and markdown attributes).

If you only need the UIKit-compatible `NSAttributedString` and want to implement the view yourself (or on watchOS), use `MarkdownGenerator.generate(string:)` (or `MarkdownGenerator.generate(string:tappedIds)` if you need spoiler support)
