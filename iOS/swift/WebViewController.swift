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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("APP_메인_웹뷰화면", screenClass: String(describing: ViewController.self))
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //ShowAlertMessage(msg: "웹페이지가 로드됩니다")
        wkMain.configuration.preferences.javaScriptEnabled = true
        
        // [START add_handler]
        //wkMain.configuration.userContentController.add(self, name: "firebase")
        // [END add_handler]
        
        
        let url_Str = "http://seoby.kr/m/a.html"
        let url = URL(string: url_Str)
        let request = URLRequest(url:url!)
        wkMain.load(request)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func movePrevpage(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func ShowAlertMessage(msg: String) {
        let alert = UIAlertController(title:"알림", message: msg, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title:"ok", style: .default) { (action) in
            
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
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
