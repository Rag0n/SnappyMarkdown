//
//  AppDelegate.swift
//  SnappyMarkdown
//
//  Created by Alexander Guschin on 07.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let t = markdownToHtml(input: "**hello world**")
        print(t)
        return true
    }
}

func markdownToHtml(input: String) -> String {
    let outString = cmark_markdown_to_html(input, input.utf8.count, 0)!
    return String(cString: outString)
}
