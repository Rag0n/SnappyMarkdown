//
//  MarkdownTextStorage.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 17.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit

class MarkdownTextStorage: NSTextStorage {
    private var backingString = NSMutableAttributedString()
    override var string: String {
        return backingString.string
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingString.attributes(at: location, effectiveRange: range)
    }
    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingString.replaceCharacters(in: range, with: str)
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        beginEditing()
        backingString.setAttributes(attrs, range: range)
        edited([.editedAttributes], range: range, changeInLength: 0)
        endEditing()
    }
