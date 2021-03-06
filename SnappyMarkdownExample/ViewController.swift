//
//  ViewController.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 07.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addArrangedSubview(editor)
        let attributes = Attributes(fontSize: 16, bold: false, italic: false, stylesheet: Stylesheet(fontFamily: "Helvetica"))
        let testString = """
        **Hello world** Hello world\n Test test
        *another test*
        ***emphasis* in bold**

        second test
        """
        let tree = Node(markdown: testString)!.elements
        let result = tree.map{ $0.render(attributes) }.joined(separator: "\n\n")
        resultLabel.attributedText = result
    }

    @IBOutlet private var resultLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    private let editor: UITextView = {
        let storage = MarkdownTextStorage()
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        return UITextView(frame: CGRect.zero, textContainer: container)
    }()
}
