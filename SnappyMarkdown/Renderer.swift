//
//  Renderer.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 17.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    convenience init(string: String, attributes: Attributes) {
        let baseFontDescriptor = UIFontDescriptor(name: attributes.stylesheet.fontFamily, size: attributes.fontSize)
        var fontTraits = UIFontDescriptorSymbolicTraits()
        if attributes.bold {
            fontTraits.formUnion(.traitBold)
        }
        if attributes.italic {
            fontTraits.formUnion(.traitItalic)
        }
        let fontDescriptor = baseFontDescriptor.withSymbolicTraits(fontTraits)!
        let font = UIFont(descriptor: fontDescriptor, size: 0)
        self.init(string: string, attributes: [NSAttributedStringKey.font: font])
    }
}

struct Stylesheet {
    let fontFamily: String
}

struct Attributes {
    var fontSize: CGFloat
    var bold: Bool
    var italic: Bool
    let stylesheet: Stylesheet

    mutating func strong() {
        bold = true
    }

    mutating func emphasis() {
        italic = true
    }
}

extension Block {
    func render(_ attributes: Attributes) -> NSAttributedString {
        switch self {
        case let .paragraph(elements):
            return elements.map { $0.render(attributes) }.joined()
        default:
            fatalError("not implemented")
        }
    }
}

extension Inline {
    func render(_ attributes: Attributes) -> NSAttributedString {
        var newAttributes = attributes
        switch self {
        case let .text(string):
            return NSAttributedString(string: string, attributes: attributes)
        case let .strong(children):
            newAttributes.strong()
            return children.map { $0.render(newAttributes) }.joined()
        case .lineBreak:
            return NSAttributedString(string: "\n")
        case .softBreak:
            return NSAttributedString(string: "\n")
        case let .emphasis(children):
            newAttributes.emphasis()
            return children.map { $0.render(newAttributes) }.joined()
        default:
            fatalError("not implemented")
        }
    }
}

extension Array where Element == NSAttributedString {
    func joined(separator: String = "") -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString(string: "") }
        let r = self[0].mutableCopy() as! NSMutableAttributedString
        for s in suffix(from: 1) {
            r.append(NSAttributedString(string: separator))
            r.append(s)
        }
        return r
    }
}
