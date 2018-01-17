//
//  NodeAST.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 16.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import Foundation


public enum Inline {
    case text(String)
    case softBreak
    case lineBreak
    case code(String)
    case html(String)
    case emphasis(children: [Inline])
    case strong(children: [Inline])
    case custom(literal: String)
    case link(title: String?, url: String?, children: [Inline])
    case image(title: String?, url: String?, children: [Inline])
}

public enum Block {
    case list([[Block]], type: ListType)
    case blockQuote([Block])
    case codeBlock(String, language: String?)
    case html(String)
    case paragraph([Inline])
    case heading([Inline], level: Int)
    case custom(literal: String)
    case thematicBreak
}

public enum ListType {
    case Unordered
    case Ordered
}

extension Inline {
    init(_ node: Node) {
        switch node.type {
        case CMARK_NODE_TEXT:
            self = .text(node.literal!)
        case CMARK_NODE_SOFTBREAK:
            self = .softBreak
        case CMARK_NODE_LINEBREAK:
            self = .lineBreak
        case CMARK_NODE_CODE:
            self = .code(node.literal!)
        case CMARK_NODE_HTML_INLINE:
            self = .html(node.literal!)
        case CMARK_NODE_CUSTOM_INLINE:
            self = .custom(literal: node.literal!)
        case CMARK_NODE_EMPH:
            self = .emphasis(children: Inline.inlineChildren(for: node))
        case CMARK_NODE_STRONG:
            self = .strong(children: Inline.inlineChildren(for: node))
        case CMARK_NODE_LINK:
            self = .link(title: node.title, url: node.urlString, children: Inline.inlineChildren(for: node))
        case CMARK_NODE_IMAGE:
            self = .image(title: node.title, url: node.urlString, children: Inline.inlineChildren(for: node))
        default:
            fatalError("Unrecognized node: \(node.typeString)")
        }
    }

    private static func inlineChildren(for node: Node) -> [Inline] {
        return node.children.map(Inline.init)
    }
}

extension Block {
    init(_ node: Node) {
        switch node.type {
        case CMARK_NODE_PARAGRAPH:
            self = .paragraph(Block.inlineChildren(for: node))
        case CMARK_NODE_BLOCK_QUOTE:
            self = .blockQuote(Block.blockChildren(for: node))
        case CMARK_NODE_LIST:
            let type: ListType = node.listType == CMARK_BULLET_LIST ? .Unordered : .Ordered
            self = .list(node.children.map { $0.listItem }, type: type)
        case CMARK_NODE_CODE_BLOCK:
            self = .codeBlock(node.literal!, language: node.fenceInfo)
        case CMARK_NODE_HTML_BLOCK:
            self = .html(node.literal!)
        case CMARK_NODE_CUSTOM_BLOCK:
            self = .custom(literal: node.literal!)
        case CMARK_NODE_HEADING:
            self = .heading(Block.inlineChildren(for: node), level: node.headerLevel)
        case CMARK_NODE_THEMATIC_BREAK:
            self = .thematicBreak
        default:
            fatalError("Unrecognized node: \(node.typeString)")
        }
    }

    private static func inlineChildren(for node: Node) -> [Inline] {
        return node.children.map(Inline.init)
    }

    private static func blockChildren(for node: Node) -> [Block] {
        return node.children.map(Block.init)
    }
}

extension String {
    init?(unsafeCString: UnsafePointer<Int8>?) {
        guard let cString = unsafeCString else { return nil }
        self.init(cString: cString)
    }
}

extension Node {
    /// The abstract syntax tree representation of a Markdown document.
    /// - returns: an array of block-level elements.
    public var elements: [Block] {
        return children.map(Block.init)
    }
}
