//
//  ViewController.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 07.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = Attributes(fontSize: 16, bold: false, stylesheet: Stylesheet(fontFamily: "Helvetica"))
        let testString = "**Hello world** Hello world"
        let tree = Node(markdown: testString)!.elements
        let result = tree[0].render(attributes)
        resultLabel.attributedText = result
    }
}

