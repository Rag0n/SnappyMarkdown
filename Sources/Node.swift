//
//  Node.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 16.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import Foundation
import libcmark

public class Node {
    let node: UnsafeMutablePointer<cmark_node>

    public init(node: UnsafeMutablePointer<cmark_node>) {
        self.node = node
    }

    public init?(markdown: String) {
        guard let node = cmark_parse_document(markdown, markdown.utf8.count, 0) else {
            return nil
        }
        self.node = node
    }

    deinit {
        guard type == CMARK_NODE_DOCUMENT else { return }
        cmark_node_free(node)
    }

    var type: cmark_node_type {
        return cmark_node_get_type(node)
    }

    var listType: cmark_list_type {
        get {
            return cmark_node_get_list_type(node)
        }
        set {
            cmark_node_set_list_type(node, newValue)
        }
    }

    var typeString: String {
        return String(cString: cmark_node_get_type_string(node)!)
    }

    var literal: String? {
        get {
            return String(unsafeCString: cmark_node_get_literal(node))
        }
        set {
            if let value = newValue {
                cmark_node_set_literal(node, value)
            } else {
                cmark_node_set_literal(node, nil)
            }
        }
    }

    var headerLevel: Int {
        get {
            return Int(cmark_node_get_heading_level(node))
        }
        set {
            cmark_node_set_heading_level(node, Int32(newValue))
        }
    }

    var title: String? {
        get {
            return String(unsafeCString: cmark_node_get_title(node))
        }
        set {
            if let value = newValue {
                cmark_node_set_title(node, value)
            } else {
                cmark_node_set_title(node, nil)
            }
        }
    }

    var urlString: String? {
        get {
            return String(unsafeCString: cmark_node_get_url(node))
        }
        set {
            if let value = newValue {
                cmark_node_set_url(node, value)
            } else {
                cmark_node_set_url(node, nil)
            }
        }
    }

    var fenceInfo: String? {
        get {
            return String(unsafeCString: cmark_node_get_fence_info(node))
        }
        set {
            if let value = newValue {
                cmark_node_set_fence_info(node, value)
            } else {
                cmark_node_set_fence_info(node, nil)
            }
        }
    }

    var listItem: [Block] {
        switch type {
        case CMARK_NODE_ITEM:
            return children.map(Block.init)
        default:
            fatalError("Unrecognized node \(typeString), expected a list item")
        }
    }

    var children: [Node] {
        var c = [Node]()
        var child = cmark_node_first_child(node)
        while let unwrapped = child {
            c.append(Node(node: unwrapped))
            child = cmark_node_next(child)
        }
        return c
    }

    /// Renders the HTML representation
    public var html: String {
        return String(cString: cmark_render_html(node, 0))
    }

    /// Renders the XML representation
    public var xml: String {
        return String(cString: cmark_render_xml(node, 0))
    }

    /// Renders the CommonMark representation
    public var commonMark: String {
        return String(cString: cmark_render_commonmark(node, CMARK_OPT_DEFAULT, 80))
    }

    /// Renders the LaTeX representation
    public var latex: String {
        return String(cString: cmark_render_latex(node, CMARK_OPT_DEFAULT, 80))
    }

    public var description: String {
        return "\(typeString) {\n \(literal ?? String())\(Array(children).description) \n}"
    }
}

extension Node {
    convenience init(element: Inline) {
        switch element {
        case let .text(text):
            self.init(type: CMARK_NODE_TEXT, literal: text)
        case let .emphasis(children):
            self.init(type: CMARK_NODE_EMPH, elements: children)
        case let .code(text):
            self.init(type: CMARK_NODE_CODE, literal: text)
        case let .strong(children):
            self.init(type: CMARK_NODE_STRONG, elements: children)
        case let .html(text):
            self.init(type: CMARK_NODE_HTML_INLINE, literal: text)
        case let .custom(literal):
            self.init(type: CMARK_NODE_CUSTOM_INLINE, literal: literal)
        case let .link(title, url, children):
            self.init(type: CMARK_NODE_LINK, elements: children)
            self.title = title
            self.urlString = url
        case let .image(title, url, children):
            self.init(type: CMARK_NODE_IMAGE, elements: children)
            self.title = title
            urlString = url
        case .softBreak:
            self.init(type: CMARK_NODE_SOFTBREAK)
        case .lineBreak:
            self.init(type: CMARK_NODE_LINEBREAK)
        }
    }
}

extension Node {
    convenience init(block: Block) {
        switch block {
        case let .paragraph(children):
            self.init(type: CMARK_NODE_PARAGRAPH, elements: children)
        case let .list(items, type):
            let listItems = items.map { Node(type: CMARK_NODE_ITEM, blocks: $0) }
            self.init(type: CMARK_NODE_LIST, children: listItems)
            listType = type == .Unordered ? CMARK_BULLET_LIST : CMARK_ORDERED_LIST
        case let .blockQuote(items):
            self.init(type: CMARK_NODE_BLOCK_QUOTE, blocks: items)
        case let .codeBlock(text, language):
            self.init(type: CMARK_NODE_CODE_BLOCK, literal: text)
            fenceInfo = language
        case let .html(text):
            self.init(type: CMARK_NODE_HTML_BLOCK, literal: text)
        case let .custom(literal):
            self.init(type: CMARK_NODE_CUSTOM_BLOCK, literal: literal)
        case let .heading(text, level):
            self.init(type: CMARK_NODE_HEADING, elements: text)
            headerLevel = level
        case .thematicBreak:
            self.init(type: CMARK_NODE_THEMATIC_BREAK)
        }
    }
}

extension Node {
    convenience init(type: cmark_node_type, children: [Node] = []) {
        self.init(node: cmark_node_new(type))
        for child in children {
            cmark_node_append_child(node, child.node)
        }
    }

    convenience init(type: cmark_node_type, literal: String) {
        self.init(type: type)
        self.literal = literal
    }

    convenience init(type: cmark_node_type, blocks: [Block]) {
        self.init(type: type, children: blocks.map(Node.init))
    }

    convenience init(type: cmark_node_type, elements: [Inline]) {
        self.init(type: type, children: elements.map(Node.init))
    }
}

extension Node {
    public convenience init(blocks: [Block]) {
        self.init(type: CMARK_NODE_DOCUMENT, blocks: blocks)
    }
}

