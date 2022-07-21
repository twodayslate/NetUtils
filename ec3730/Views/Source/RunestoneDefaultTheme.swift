import Runestone
import SwiftUI
import UIKit

final class RunestoneDefaultTheme: Theme {
    fileprivate enum HighlightName: String {
        case `operator`
        case keyword
        case variable
        case string
        case comment
        case number
        case constant
        case constantBuiltin = "constant.builtin"
        case property
        case punctuationBracket = "punctuation.bracket"
        case punctuationDelimiter = "punctuation.delimiter"
        case attribute
        case constructor
        case delimiter
        case escape
        case field
        case function
        case functionBuiltin = "function.builtin"
        case functionMethod = "function.method"
        case punctuationSpecial = "punctuation.special"
        case stringSpecial = "string.special"
        case tag
        case type
        case typeBuiltin = "type.builtin"
        case variableBuiltin = "variable.builtin"
    }

    let textColor: UIColor = .label
    let font = UIFont(name: "Menlo-Regular", size: 14)!

    let gutterBackgroundColor: UIColor = .secondarySystemBackground
    let gutterHairlineColor: UIColor = .opaqueSeparator

    let lineNumberColor: UIColor = .secondaryLabel
    let lineNumberFont = UIFont(name: "Menlo-Regular", size: 14)!

    let selectedLineBackgroundColor: UIColor = .secondarySystemBackground
    let selectedLinesLineNumberColor: UIColor = .label
    let selectedLinesGutterBackgroundColor = UIColor.opaqueSeparator.withAlphaComponent(0.4)

    let invisibleCharactersColor: UIColor = .tertiaryLabel

    let pageGuideBackgroundColor: UIColor = .secondarySystemBackground
    let pageGuideHairlineColor: UIColor = .opaqueSeparator

    let markedTextBackgroundColor: UIColor = .systemFill
    let markedTextBackgroundBorderColor: UIColor = .clear

    func textColor(for rawHighlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(rawHighlightName) else {
            return nil
        }
        switch highlightName {
        case .punctuationBracket, .punctuationDelimiter:
            return .secondaryLabel
        case .operator:
            return .lightGray
        case .comment:
            return .secondaryLabel
        case .variable:
            return UIColor(Color.accentColor)
        case .keyword:
            return .systemPurple
        case .string:
            return .systemGreen
        case .number:
            return .systemOrange
        case .property:
            return .systemBlue
        case .constant:
            return .systemOrange
        case .constantBuiltin:
            return .systemRed
        case .attribute:
            return .systemGray
        case .constructor:
            return .systemGray2
        case .delimiter:
            return .systemGray3
        case .escape:
            return .systemGray4
        case .field:
            return .systemGray5
        case .function:
            return .systemGray6
        case .functionBuiltin:
            return .systemCyan
        case .functionMethod:
            return .systemPink
        case .punctuationSpecial:
            return .systemBrown
        case .stringSpecial:
            return .systemMint.withAlphaComponent(0.8)
        case .tag:
            return .darkGray
        case .type:
            return .systemRed
        case .typeBuiltin:
            return .systemBlue
        case .variableBuiltin:
            return UIColor(Color.accentColor)
        }
    }

    func font(for rawHighlightName: String) -> UIFont? {
        guard let highlightName = HighlightName(rawHighlightName) else {
            return nil
        }
        switch highlightName {
        case .keyword:
            return UIFont(name: "Menlo-Bold", size: 14)!
        default:
            return nil
        }
    }
}

private extension RunestoneDefaultTheme.HighlightName {
    init?(_ rawHighlightName: String) {
        // From the Tree-sitter documentation:
        //
        //   For a given highlight produced, styling will be determined based on the longest matching theme key.
        //   For example, the highlight function.builtin.static would match the key function.builtin rather than function.
        //
        //  https://tree-sitter.github.io/tree-sitter/syntax-highlighting
        var comps = rawHighlightName.split(separator: ".")
        var result: Self?
        while result == nil, !comps.isEmpty {
            let rawValue = comps.joined(separator: ".")
            result = Self(rawValue: rawValue)
            comps.removeLast()
        }
        if let result = result {
            self = result
        } else {
            return nil
        }
    }
}
