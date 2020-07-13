//
//  WebViewController.swift
//  com.lpointdsc.ios
//
//  Created by 손경섭 on 2020. 6. 10..
//  Copyright © 2020년 손경섭. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Firebase

class WebViewController : UIViewController {
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet var wkMain: WKWebView!
    
    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "firebase")
        webConfig.userContentController = contentController
        wkMain = WKWebView(frame: .zero, configuration: webConfig)
        view = wkMain
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Webview javascript Enabled = true
        wkMain.configuration.preferences.javaScriptEnabled = true
        
        let url_Str = "{{페이지URL}}"
        let url = URL(string: url_Str)
        let request = URLRequest(url:url!)
        wkMain.load(request)
    }
}

extension WebViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        guard let command = body["command"] as? String else { return }
        guard let name = body["name"] as? String else { return }
        
        if command == "setUserProperty" {
            guard let value = body["value"] as? String else { return }
            Analytics.setUserProperty(value, forName: name)
        } else if command == "logEvent" {
            guard let params = body["parameters"] as? [String: NSObject] else { return }
            Analytics.logEvent(name, parameters: params)
        } else if command == "setScreenName" {
            guard let screen_name = body["screen_name"] as? String else { return }
            Analytics.setScreenName(screen_name, screenClass: String(describing: ViewController.self))
        }
    }
}
