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
            let boldFontTrait = UIFontDescriptorSymbolicTraits.traitBold
            fontTraits.formUnion(boldFontTrait)
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
    let stylesheet: Stylesheet

    mutating func strong() {
        bold = true
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
        default:
            fatalError("not implemented")
        }
    }
}

extension Array where Element == NSAttributedString {
    func joined() -> NSAttributedString {
        let r = NSMutableAttributedString()
        for s in self {
            r.append(s)
        }
        return r
    }
}
