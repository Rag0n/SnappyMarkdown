//
//  MarkdownTextStorage.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 17.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit
import libcmark

class MarkdownTextStorage: NSTextStorage {
    private var backingString = NSMutableAttributedString()

    public override init() {
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var string: String {
        return backingString.string
    }

    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        print("attributesAt:\(location) effectiveRange:\(String(describing: range))")
        return backingString.attributes(at: location, effectiveRange: range)
    }

    override public func replaceCharacters(in range: NSRange, with str: String) {
        print("replaceCharactersInRange:\(range) withString:\(str)")
        backingString.replaceCharacters(in: range, with: str)
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
    }

    override public func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        print("setAttributes")
//        print("setAttributes:\(String(describing: attrs)) range:\(range)")
//        backingString.setAttributes(attrs, range: range)
//        edited([.editedAttributes], range: range, changeInLength: 0)
    }

    override public func processEditing() {
        print("PROCESS")
        self.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: editedRange)
//        self.string.paragraphRange(for: <#T##RangeExpression#>)
//        let attributes = Attributes(fontSize: 16, bold: false, italic: false, stylesheet: Stylesheet(fontFamily: "Helvetica"))
//        let tree = Node(markdown: self.string)!.elements
//        self.backingString = tree.map{ $0.render(attributes) }.joined(separator: "\n\n").mutableCopy() as NSMutableAttributedString

        super.processEditing()
    }
}
