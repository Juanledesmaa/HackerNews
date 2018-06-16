//
//  NewsDetailController.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import UIKit

class NewsDetailController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webview: UIWebView!
    var passedLink = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if (checkConnection()) {
            self.loadLink()
        } else {
            self.view.makeToast("No connection available")
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLink() {
        let url = URL(string: passedLink)
        let request = NSURLRequest(url: url!)
        self.webview.loadRequest(request as URLRequest)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        return true
    }
}
